require 'bundler/setup'
require 'json'
require 'yaml'
require 'filesize'

# common config file
dashing_config = './config.yaml'
config = YAML.load_file(dashing_config)

points_rd = []
points_wr = []
(1..10).each do |i|
  points_rd << { x: i, y: 0 }  # graph 1 initialization
  points_wr << { x: i, y: 0 }  # graph 2 initialization
end

# detect if ceph osd pool stats is available (>=emperor)
result = %x( ceph osd pool stats -f json 2>&1)
begin
  poolstats = JSON.parse(result)
  poolstats_available = true
rescue
  poolstats_available = false
end

SCHEDULER.every '2s' do

  points_rd.shift
  points_wr.shift
  points_rd << { x: points_rd.last[:x] + 1, y: 0 }
  points_wr << { x: points_rd.last[:x] + 1, y: 0 }


  # if ceph osd pool stats is available, get the rw stats from that.
  # otherwise, use ceph status, available in dumpling.
  if poolstats_available
    result = %x( timeout 2 ceph osd pool stats -f json )
    poolstats = JSON.parse(result)

    poolstats.each do |poolstat|
      if poolstat['client_io_rate'].has_key?('read_bytes_sec')
        points_rd.last[:y] = points_rd.last[:y] + poolstat['client_io_rate']['read_bytes_sec'].to_i
      end
      if poolstat['client_io_rate'].has_key?('write_bytes_sec')
        points_wr.last[:y] = points_wr.last[:y] + poolstat['client_io_rate']['write_bytes_sec'].to_i
      end
    end
  else
    result = %x( timeout 2 ceph status -f json )
    status = JSON.parse(result)

    if status['pgmap'].has_key?('read_bytes_sec')
      points_rd.last[:y] = points_rd.last[:y] + status['pgmap']['read_bytes_sec'].to_i
    end
    if status['pgmap'].has_key?('write_bytes_sec')
      points_wr.last[:y] = points_wr.last[:y] + status['pgmap']['write_bytes_sec'].to_i
    end
  end

  send_event('traffic',
    {
      points: [points_rd, points_wr],
      moreinfo: Filesize.from("#{points_rd.last[:y]} B").pretty + " / " + Filesize.from("#{points_wr.last[:y]} B").pretty
    })
end
