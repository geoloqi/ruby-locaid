# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "locaid/version"

Gem::Specification.new do |s|
  s.name        = "locaid"
  s.version     = Locaid::VERSION
  s.authors     = ["Kyle Drake"]
  s.email       = ["kyledrake@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "locaid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'geoloqi'
  s.add_dependency 'savon'
  s.add_dependency 'hashie'

  s.add_development_dependency "ruby-debug19"
  # s.add_runtime_dependency "rest-client"
end
