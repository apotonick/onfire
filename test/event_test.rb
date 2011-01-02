require 'test_helper'

class EventTest < Test::Unit::TestCase
  context "An event" do
    should "accept its type and source in the constructor" do
      event = Onfire::Event.new(:click, :source)
      
      assert_equal :click,  event.type
      assert_equal :source, event.source
      assert_nil  event.data
    end
    
    should "be fine without any parameters at all" do
      event = Onfire::Event.new
      
      assert_nil  event.type
      assert_nil  event.source
      assert_nil  event.data
    end
    
    should "accept payload data" do
      event = Onfire::Event.new(:drag, :source, :target => 'me')
      
      assert_equal :drag,   event.type
      assert_equal :source, event.source
      assert_equal({:target => 'me'}, event.data)
    end
    
    should "stop if needed" do
      event = Onfire::Event.new
      
      assert ! event.stopped?
      event.stop!
      assert event.stopped?
    end
  end
end
