require 'rubygems'
require 'shoulda'
require 'onfire'

class Onfire::EventTable
  def size
    source2evt.inject(0)do |memo, evts| 
      memo + evts[1].inject(0) {|sum, h| sum + h[1].size} # h => [key, value].
    end || 0
  end
end

class Test::Unit::TestCase
  def mock(name='my_mock')
    obj = Class.new do
      include Onfire
      
      attr_accessor :list, :name, :parent
      
      def initialize(name)
        @name = name
        @list = []
      end
    end.new(name)
  end
end
