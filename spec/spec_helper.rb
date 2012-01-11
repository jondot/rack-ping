require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'

include Rack::Test::Methods
def r
  last_response
end
