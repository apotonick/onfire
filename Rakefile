# encoding: utf-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'onfire', 'version')

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the onfire library.'
Rake::TestTask.new(:test) do |test|
  test.libs << ['lib', 'test']
  test.pattern = 'test/*_test.rb'
  test.verbose = true
end


# Gem managment tasks.
#
# == Bump gem version (any):
#
#   rake version:bump:major
#   rake version:bump:minor
#   rake version:bump:patch
#
# == Generate gemspec, build & install locally:
#
#   rake gemspec
#   rake build
#   sudo rake install
#
# == Git tag & push to origin/master
#
#   rake release
#
# == Release to Gemcutter.org:
#
#   rake gemcutter:release
#
begin
  gem 'jeweler'
  require 'jeweler'

  Jeweler::Tasks.new do |spec|
    spec.name         = "onfire"
    spec.version      = ::Onfire::VERSION
    spec.summary      = %{Have bubbling events and observers in all your Ruby objects.}
    spec.description  = spec.summary
    spec.homepage     = "http://github.com/apotonick/onfire"
    spec.authors      = ["Nick Sutterer"]
    spec.email        = "apotonick@gmail.com"

    spec.files = FileList["[A-Z]*", File.join(*%w[{lib,test} ** *]).to_s]

    # spec.add_dependency 'activesupport', '>= 2.3.0' # Dependencies and minimum versions?
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler - or one of its dependencies - is not available. " <<
  "Install it with: sudo gem install jeweler -s http://gemcutter.org"
end
