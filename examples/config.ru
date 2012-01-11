require 'rack/ping'

map '/ping' do
  use Rack::Ping do |ping|
    ping.check_url  "http://localhost:9292/"
    ping.ok_regex /goodbye/
  end
end

run lambda{|env| [200, {'Content-Type' => 'text/html'}, ["hello"]]}
