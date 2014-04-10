require 'bundler/setup'
require 'yaml'

# common config file
dashing_config = './config.yaml'
config = YAML.load_file(dashing_config)

SCHEDULER.every '5s' do

  result = %x( timeout 3 ceph health )

  if result =~ /.*HEALTH_WARN.*/m
    status = 'warn'
  elsif result =~ /.*HEALTH_ERR.*/m
    status = 'err'
  else
    status = 'ok'
  end

  send_event('status', { status: status, text: result } )

end
