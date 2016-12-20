require 'bundler/setup'
require 'json'
require 'yaml'
require 'filesize'

# common config file
dashing_config = './config.yaml'
config = YAML.load_file(dashing_config)

last = {}
config['pools'].keys.each do |name|
    last[name] = 0
end

SCHEDULER.every '5s' do

  result = %x( timeout 3 ceph df -f json )

  # update total storage widget
  # *updated this to work with Jewel release
  storage = JSON.parse(result)
  used = storage['stats']['total_used_bytes'].to_i
  total = storage['stats']['total_bytes'].to_i
  
  #Percentage was not showing the right ratio, changed vaule by replacing pretty with .to_s('TB')
    #this really should be done with the Max value as well to make sure no matter the size
    # Both values are in the same size value
  send_event('storage',
    {
      value: Filesize.from("#{used} B").to_s('TB').split(' ').first.to_f,
      min: 0,
      max: Filesize.from("#{total} B").pretty.split(' ').first.to_f,
      #max:storage['stats']['total_bytes'].pretty.to_i,
      moreinfo: Filesize.from("#{used} B").pretty + " out of " + Filesize.from("#{total} B").pretty
    }
  )

  # update each of the config pools widgets
  config['pools'].keys.each_with_index do |poolname, index|
    for pool in storage['pools'] do
      if pool['name'] == poolname
        send_event("pool#{index}", { current: pool['stats']['bytes_used'], last: last[pool['name']],
                                     title: config['pools'][poolname]['display_name'] } )
        last[pool['name']] = pool['stats']['bytes_used']
      end
    end
  end

end
