require 'bundler/setup'
require 'json'
require 'yaml'

# common config file
dashing_config = './config.yaml'
config = YAML.load_file(dashing_config)

last = {}
config['pools'].each do |name|
    last[name] = 0
end

SCHEDULER.every '5s' do

  result = %x( ceph df -f json )

  # update total storage widget
  storage = JSON.parse(result)
  send_event('storage', { value: storage['stats']['total_used'].to_i, min: 0, max: storage['stats']['total_space'].to_i } )

  # update each of the config pools widgets
  storage['pools'].each do |pool|
    if config['pools'].include? pool['name']
      send_event("pool-#{pool['name']}", { current: pool['stats']['bytes_used'], last: last[pool['name']] } )
      last[pool['name']] = pool['stats']['bytes_used']
    end
  end

end
