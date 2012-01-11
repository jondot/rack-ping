# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/version"

Gem::Specification.new do |s|
  s.name        = "rack-ping"
  s.version     = Rack::Ping::VERSION
  s.authors     = ["Dotan Nahum"]
  s.email       = ["jondotan@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Health checking Rack middleware}
  s.description = %q{Health checking Rack middleware}

  s.rubyforge_project = "rack-ping"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'guard-minitest'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'webmock'
end
