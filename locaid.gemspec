# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "locaid/version"

Gem::Specification.new do |s|
  s.name        = "locaid"
  s.version     = Locaid::VERSION
  s.authors     = ["Kyle Drake"]
  s.email       = ["kyledrake@gmail.com"]
  s.homepage    = "http://www.loc-aid.com"
  s.summary     = %q{Interface for the Locaid API}
  s.description = %q{Interface for use with the Locaid API}

  s.rubyforge_project = "locaid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'geoloqi'
  s.add_dependency 'savon'
  s.add_dependency 'hashie'
  s.add_dependency 'rest-client'
end
