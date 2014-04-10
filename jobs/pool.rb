require 'bundler/setup'
require 'json'
require 'yaml'

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
  storage = JSON.parse(result)
  send_event('storage', { value: storage['stats']['total_used'].to_i, min: 0, max: storage['stats']['total_space'].to_i } )

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
