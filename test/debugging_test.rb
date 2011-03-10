require 'test_helper'
require 'onfire/debugging'

class DebuggingTest < Test::Unit::TestCase
  attr_reader :list
  
  context "mixing in the Debugging module" do
    setup do
      @barkeeper  = mock('barkeeper')
      @guest      = mock('guest')
      @guest.parent = @barkeeper
      
      
      @evt_class = Class.new(Onfire::Event)
      @evt_class.class_eval do
        include Onfire::Event::Debugging
      end
    end
    
    context ".debug" do
      should "set debug_event_blocks" do
        @proc_1 = Proc.new {}
        @proc_2 = Proc.new {}
        
        @evt_class.debug &@proc_1
        @evt_class.debug &@proc_1
        
        assert_equal [@proc_1, @proc_2], @evt_class.debug_blocks
      end
    end
    
    context "#bubble!" do
      setup do
        @list = ""
        @evt_class.debug do |node, evt|
          list << "@ #{node.name} with event type #{evt.type}"
        end
      end
      
      should "be invoked at every node" do
        @evt_class.new(:cheers, @barkeeper).bubble!
        
        assert_equal "@ barkeeper with event type cheers", list
      end
      
      should "call the debug blocks at every processing step" do
        @guest.on :cheers do
          list << " | Cheers!"
        end
        @evt_class.new(:cheers, @guest).bubble!
        
        assert_equal "@ guest with event type cheers | Cheers!@ barkeeper with event type cheers", @list
      end
    end
  end
end
