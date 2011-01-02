# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "onfire/version"

Gem::Specification.new do |s|
  s.name        = "onfire"
  s.version     = Onfire::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Sutterer"]
  s.email       = ["apotonick@gmail.com"]
  s.homepage    = "http://github.com/apotonick/onfire"
  s.summary     = %q{Have bubbling events and observers in all your Ruby objects.}
  s.description = %q{Have bubbling events and observers in all your Ruby objects.}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
