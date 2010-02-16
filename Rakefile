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