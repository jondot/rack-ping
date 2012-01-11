require 'spec_helper'
require 'rack/ping'


def app
  lambda{|env| [200, {'Content-Type' => 'text/html'}, ["hello"]]}
end

def must_bust_cache(h)
  h["Cache-Control"].must_equal "no-cache, no-store, max-age=0, must-revalidate"
  h["Pragma"].must_equal "no-cache"
  h["Expires"].must_equal "Tue, 8 Sep 1981 08:42:00 UTC"
end

describe Rack::Ping do
  it "should bust cache" do
    s, h, b = Rack::Ping.new(app).call({})
    must_bust_cache(h)
  end

  it "should have sane defaults" do
    # when ok
    s, h, b = Rack::Ping.new(app).call({})
 
    s.must_equal 200
    h['x-app-version'].must_equal '0'
    b[0].must_equal 'ok'
    must_bust_cache(h)

    # when error
    s, h, b = Rack::Ping.new(app) do |ping| 
      ping.check { false } 
    end.call({})

    s.must_equal 500
    b[0].must_equal 'error'
    must_bust_cache(h)
  end

  module MyApp
    VERSION = '1.0.0'
  end

  it "should pick up application version" do
    s, h, b = Rack::Ping.new(app) do |ping| 
      ping.version MyApp::VERSION
    end.call({})
    h['x-app-version'].must_equal '1.0.0'
  end


  it "should run check code when available" do
    s, h, b = Rack::Ping.new(app) do |ping|
      ping.check do
        false
      end
    end.call({})

    s.must_equal 500
    b[0].must_equal 'error'
    h['x-ping-error'].must_equal "logic"
    must_bust_cache(h)


    s, h, b = Rack::Ping.new(app) do |ping|
      ping.check do
        raise "error"
      end
    end.call({})

    s.must_equal 500
    b[0].must_equal 'error'
    h['x-ping-error'].must_equal "logic: error"
    must_bust_cache(h)
  end

  it "should fetch url content and run regex on it when available" do
    stub_request(:any, "http://google.com").to_return(:body => "google is awesome")
    s, h, b = Rack::Ping.new(app) do |ping|
      ping.check_url "http://google.com"
      ping.ok_regex /awesome/
      ping.ok_text "groovy"
    end.call({})

    s.must_equal 200
    b[0].must_equal 'groovy'
    must_bust_cache(h)


    s, h, b = Rack::Ping.new(app) do |ping|
      ping.check_url "http://google.com"
      ping.ok_regex /bing/
      ping.ok_text "groovy"
    end.call({})

    s.must_equal 500
    b[0].must_equal 'error'
    must_bust_cache(h)
  end

  it "should timeout when resource at url is unavailable" do
    stub_request(:any, "http://google.com").to_timeout
    s, h, b = Rack::Ping.new(app) do |ping|
      ping.check_url "http://google.com"
      ping.ok_regex /awesome/
      ping.error_text "shitty"
    end.call({})

    s.must_equal 500
    b[0].must_equal 'shitty'
    h['x-ping-error'].must_equal "timeout"
    must_bust_cache(h)
  end

end
