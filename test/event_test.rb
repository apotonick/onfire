require File.dirname(__FILE__) + '/test_helper'

class EventTest < Test::Unit::TestCase
  context "An event" do
    should "accept its type and source in the constructor" do
      event = Onfire::Event.new(:click, :source)
      
      assert_equal :click,  event.type
      assert_equal :source, event.source
    end
    
    should "be fine without any parameters at all" do
      event = Onfire::Event.new
      
      assert_nil  event.type
      assert_nil  event.source
      assert_nil  event.data
    end
    
    should "stop if needed" do
      event = Onfire::Event.new
      
      assert ! event.stopped?
      event.stop!
      assert event.stopped?
    end
  end
end