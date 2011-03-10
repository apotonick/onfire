require 'test_helper'

class OnfireTest < Test::Unit::TestCase
  context "including Onfire" do
    should "provide event_table accessors to an emtpy table" do
      table = mock.event_table
      assert_kind_of Onfire::EventTable, table
      assert_equal 0, table.size
    end
  end
  
  context "In the bar" do
    setup do
      @barkeeper   = mock('barkeeper')
      @nice_guest  = mock('nice guest')
      @bad_guest   = mock('bad guest')
      
      @nice_guest.parent = @barkeeper
      @bad_guest.parent  = @barkeeper
    end
    
    context "the #on method" do
      context "with the :from option for filtering" do
        setup do
          @barkeeper.on(:order, :from => @nice_guest) {@barkeeper.list << 'be nice'}
          @barkeeper.on(:order, :from => @bad_guest)  {@barkeeper.list << 'ignore'}
          @barkeeper.on(:order, :from => @bad_guest)  {@barkeeper.list << 'throw out'}
        end
      
        should "invoke the handler for the nice guest only" do
          @nice_guest.fire :order
          assert_equal ['be nice'], @barkeeper.list
        end
        
        should "invoke both handlers for the bad guest only" do
          @bad_guest.fire :order
          assert_equal ['ignore', 'throw out'], @barkeeper.list
        end
        
        should "invoke an additional catch-all handler" do
          @barkeeper.on(:order) {@barkeeper.list << 'have a drink yourself'}
          @nice_guest.fire :order
          assert_equal ['be nice', 'have a drink yourself'], @barkeeper.list
        end
        
        should "invoke another handler when :from is nil" do
          @barkeeper.on(:order, :from => nil) {@barkeeper.list << 'have a drink yourself'}
          @nice_guest.fire :order
          assert_equal ['be nice', 'have a drink yourself'], @barkeeper.list
        end
        
        should "invoke :from handlers before it processes catch-all handlers" do
          @barkeeper.on(:order)                         {@barkeeper.list << 'have a drink yourself'}
          @barkeeper.on(:order, :from => @nice_guest)   {@barkeeper.list << 'bring out toast'}
          @nice_guest.fire :order
          assert_equal ['be nice', 'bring out toast', 'have a drink yourself'], @barkeeper.list
        end
      end
      
      context "with a callable object" do
        setup do
          @callable = Class.new.new
          @callable.instance_eval do
            def call(event)
              source = event.source
              return source.list << 'order from barkeeper' unless source.parent
              source.parent.list << 'order from guest'
            end
          end
        end
        
        should "add a handler to the local event_table" do
          @barkeeper.on :order, :call => @callable
          
          @barkeeper.fire :order
          assert_equal ['order from barkeeper'], @barkeeper.list
          
          @nice_guest.fire :order
          assert_equal ['order from barkeeper', 'order from guest'], @barkeeper.list
        end
      end
    end
    
    
    context "#event_table" do
      should "expose the EventTable to the public" do
        assert_kind_of ::Onfire::EventTable, @barkeeper.event_table
      end
    end
    
  end
  
  context "calling #fire" do
    setup do
      @obj = mock
    end
    
    should "invoke the attached matching handler" do
      @obj.on :click do @obj.list << 1 end
      @obj.fire :click
      
      assert_equal [1], @obj.list
    end
    
    should "not invoke same handlers for :symbol or 'string' event names" do
      @obj.on :click do @obj.list << 1 end
      @obj.fire 'click'
      
      assert_equal [], @obj.list
    end
    
    should "allow appending arbitrary data to the event" do
      # we use @obj for recording the chat.
      bar   = mock('bar')
      
      bar.on :thirsty do |evt|
        @obj.list << "You look like #{evt.data[:who]} need a drink."
      end
      
      bar.fire :thirsty, :who => "I"
      
      assert_equal ["You look like I need a drink."], @obj.list
    end
    
    # FUNCTIONAL: (onfire context)
    context "#event_for" do
      setup do
        @obj.on :thirsty do |evt|
          @obj.list << evt
        end
      end
      
      should "respect #event_for" do
        @obj.fire :thirsty
        
        assert_kind_of Onfire::Event, @obj.list.first
      end
      
      # FUNCTIONAL: (onfire context)
      should "respect an overridden #event_for" do
        class LocalEvent < Onfire::Event
        end
        
        @obj.instance_eval do
          def event_for(*args)
            LocalEvent.new(*args)
          end
        end
        @obj.fire :thirsty
        
        assert_kind_of LocalEvent, @obj.list.first
      end
    end
  end
end
