require 'bundler/setup'
require 'json'
require 'yaml'

# common config file
dashing_config = './config.yaml'
config = YAML.load_file(dashing_config)

points_rd = []
points_wr = []
(1..10).each do |i|
  points_rd << { x: i, y: 0 }  # graph 1 initialization
  points_wr << { x: i, y: 0 }  # graph 2 initialization
end
 
SCHEDULER.every '2s' do
  
  result = %x( ceph osd pool stats -f json )
  poolstats = JSON.parse(result)

  points_rd.shift
  points_wr.shift
  points_rd << { x: points_rd.last[:x] + 1, y: 0 }
  points_wr << { x: points_rd.last[:x] + 1, y: 0 }
  poolstats.each do |poolstat|
    if poolstat['client_io_rate'].has_key?('read_bytes_sec')
      points_rd.last[:y] = points_rd.last[:y] + poolstat['client_io_rate']['read_bytes_sec'].to_i
    end
    if poolstat['client_io_rate'].has_key?('write_bytes_sec')
      points_wr.last[:y] = points_wr.last[:y] + poolstat['client_io_rate']['write_bytes_sec'].to_i
    end
  end

  send_event('traffic', points: [points_rd, points_wr])
end
