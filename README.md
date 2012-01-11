# Rack::Ping
A Rack middleware that should indicate the health of your service.


## Usage

use Rack::Ping do |ping|
  ping.version = "4.0"
  ping.check_url = "http://localhost:234/api"
  ping.ok_regex = /Welcome to Acme API/
  ping.ok_text = 'ok'
  ping.ok_code = 200
end
