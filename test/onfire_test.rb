require File.dirname(__FILE__) + '/test_helper'

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
      table = mock.send :event_table
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
      obj.send(:event_table).add_handler(lambda{obj.list << 1}, :event_type => :click)
      
      obj.process_event(@event)
      
      assert_equal [1], obj.list
    end
    
    should "not invoke procs for another event_type" do
      obj = mock
      obj.send(:event_table).add_handler(lambda{obj.list << 1}, :event_type => :click)
      obj.send(:event_table).add_handler(lambda{obj.list << 2}, :event_type => :drop) # don't call me!
      
      obj.process_event(@event)
      
      assert_equal [1], obj.list
    end
  end
  
  context "calling #on" do
    setup do
      @obj    = mock
      @event  = Onfire::Event.new(:click, @obj)
    end
    
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
  
  context "calling #on with :from" do
    should_eventually "only be invoked on events from :from"
  end
  
  
  context "stopping events" do
    should_eventually "not invoke any handler above and next to the stopping"
  end
  
  
  context "calling #fire" do
    setup do
      @obj    = mock
    end
    
    should "be of no relevance when there are no handlers attached" do
      @obj.fire :click
      
      assert_equal [], @obj.list
    end
    
    should "invoke the attached handler" do
      @obj.on :click do @obj.list << 1 end
      @obj.fire :click
      
      assert_equal [1], @obj.list
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