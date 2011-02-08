require 'test_helper'

class OnfireTest < Test::Unit::TestCase
  def mock(name='my_mock')
    obj = Class.new do
      attr_accessor :list
      attr_accessor :name
      attr_accessor :parent
      
      include Onfire
      
      def initialize(name)
        @name = name
        @list = []
      end
    end.new(name)
  end
  
  context "including Onfire" do
    should "provide event_table accessors to an emtpy table" do
      table = mock.event_table
      assert_kind_of Onfire::EventTable, table
      assert_equal 0, table.size
    end
  end
  
  context "#process_event" do
    setup do
      @event = Onfire::Event.new(:click, mock)
    end
    
    
    should "not fill #list as there are no event handlers attached" do
      obj = mock
      obj.process_event(@event)
      
      assert_equal [], obj.list
    end
    
    should "invoke exactly one proc and thus push `1` onto #list" do
      obj = mock
      obj.event_table.add_handler(lambda { |evt| obj.list << 1 }, :event_type => :click)
      
      obj.process_event(@event)
      
      assert_equal [1], obj.list
    end
    
    should "not invoke procs for another event_type" do
      obj = mock
      obj.event_table.add_handler(lambda { |evt| obj.list << 1 }, :event_type => :click)
      obj.event_table.add_handler(lambda { |evt| obj.list << 2 }, :event_type => :drop) # don't call me!
      
      obj.process_event(@event)
      
      assert_equal [1], obj.list
    end
  end
  
  context "calling #on" do
    setup do
      @obj    = mock
      @event  = Onfire::Event.new(:click, @obj)
    end
    
    context "with a block" do
      should "add a handler to the event_table when called with a block" do
        @obj.on :click do
          @obj.list << 1
        end
        
        @obj.process_event(@event)
        assert_equal [1], @obj.list
      end
      
      should "invoke two handlers if called twice" do
        @obj.on :click do @obj.list << 1 end
        @obj.on :click do @obj.list << 2 end
        
        @obj.process_event(@event)
        assert_equal [1,2], @obj.list
      end
      
      should "receive the triggering event as parameter" do
        @obj.on :click do |evt|
          @obj.list << evt
        end
        
        @obj.process_event(@event)
        assert_equal [@event], @obj.list
      end
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
              return source.list << 'order from barkeeper' if source.root?
              source.parent.list << 'order from guest'
            end
          end
        end
        
        should "add a handler to the local event_table" do
          @barkeeper.on :order, :do => @callable
          
          @barkeeper.fire :order
          assert_equal ['order from barkeeper'], @barkeeper.list
          
          @nice_guest.fire :order
          assert_equal ['order from barkeeper', 'order from guest'], @barkeeper.list
        end
      end
    end
    
    
    context "stopping events" do
      should "not invoke any handler after the guest kills it" do
        @nice_guest.on(:order) {@nice_guest.list << 'thirsty?'}
        @nice_guest.on(:order) do |evt|
          @nice_guest.list << 'money?'
          evt.stop!
        end
        @barkeeper.on(:order)  {@nice_guest.list << 'draw a beer'}
        @nice_guest.fire :order
        
        assert_equal ['thirsty?', 'money?'], @nice_guest.list
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
    
    should "be of no relevance when there are no handlers attached" do
      @obj.fire :click
      
      assert_equal [], @obj.list
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
    
    
    should "invoke handlers in the correct order when bubbling" do
      # we use @obj for recording the chat.
      bar   = mock('bar')
      guest = mock('guest')
      
      guest.parent = bar
      guest.on :thirsty do
        @obj.list << 'A beer!'
        guest.fire :order
      end
      guest.on :thirsty do
        @obj.list << 'Hurry up, man!'
      end
      bar.on :thirsty do
        @obj.list << 'Thanks.'
      end
      bar.on :order do
        @obj.list << 'There you go.'
      end
      
      guest.fire :thirsty
      
      assert_equal ['A beer!', 'There you go.', 'Hurry up, man!', 'Thanks.'], @obj.list
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
  
  
  context "#root?" do
    setup do
      @obj    = mock
    end
    
    should "return false if we got parents" do
      @obj.parent = :daddy
      assert !@obj.root?
    end
    
    should "return true if we're at the top" do
      assert @obj.root?
    end
  end
  
end
