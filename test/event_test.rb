require 'test_helper'

class EventTest < Test::Unit::TestCase
  context "An event" do
    should "accept type and source in the constructor" do
      event = Onfire::Event.new(:click, :source)
      
      assert_equal :click,  event.type
      assert_equal :source, event.source
      assert_nil  event.data
    end
    
    should "accept payload data" do
      event = Onfire::Event.new(:drag, :source, :target => 'me')
      
      assert_equal :drag,   event.type
      assert_equal :source, event.source
      assert_equal({:target => 'me'}, event.data)
    end
    
    should "stop if needed" do
      event = Onfire::Event.new(:drag, :source)
      
      assert ! event.stopped?
      event.stop!
      assert event.stopped?
    end
  end
end
  
class EventFunctionalTest < Test::Unit::TestCase
  context "#bubble!" do
    setup do
      @guest      = mock('guest')
      @barkeeper  = mock("barkeeper")
      @event      = Onfire::Event.new(:cheers, @guest)
      @event.data = {:list => []}
    end
    
    should "visit a root source without handlers" do
      @event.bubble!
      assert_equal [], @event.data[:list]
    end
    
    should "visit the source with multiple handlers when it's root" do
      @guest.on :cheers do |evt|
        evt.data[:list] << "yo"
      end
      
      @guest.on :cheers do |evt|
        evt.data[:list] << "man"
      end
      
      @event.bubble!
      assert_equal ["yo", "man"], @event.data[:list]
    end
    
    should "call appropriate handlers, only" do
      @guest.on :cheers do |evt|
        evt.data[:list] << "yo"
      end
      
      @guest.on :drink do |evt|
        evt.data[:list] << "yummy"
      end
      
      @event.bubble!
      assert_equal %w(yo), @event.data[:list]
    end
    
    should "visit all elements in the path" do
      @guest.parent = @barkeeper
      
      @barkeeper.on :cheers do |evt|
        evt.data[:list] << "Thanks!" 
      end
      
      @guest.on :cheers do |evt|
        evt.data[:list] << "yo!"
      end
      
      @guest.on :cheers do |evt|
        evt.data[:list] << "Cheers!"
      end
      
      @event.bubble!
      assert_equal %w(yo! Cheers! Thanks!), @event.data[:list]
    end
    
    should "invoke handlers in correct order when having nested triggers" do
      list = []
      @guest.parent = @barkeeper
      
      @guest.on :cheers do
        list << 'Cheers!'
        @guest.fire :order
      end
      @guest.on :cheers do
        list << 'Hey!'
      end
      @barkeeper.on :cheers do
        list << 'Thanks.'
      end
      @barkeeper.on :order do
        list << 'Enjoy.'
      end
      
      @event.bubble!
      
      assert_equal %w(Cheers! Enjoy. Hey! Thanks.), list
    end
    
    should "not invoke any handler after being stopped" do
      @guest.parent = @barkeeper
      
      @barkeeper.on :cheers do |evt|
        evt.data[:list] << "Thanks!" 
      end
      
      @guest.on :cheers do |evt|
        evt.data[:list] << "yo!"
        evt.stop!
      end
      
      @event.bubble!
      assert_equal %w(yo!), @event.data[:list]
    end
  end
end
