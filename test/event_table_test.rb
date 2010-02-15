require File.dirname(__FILE__) + '/test_helper'

class EventTableTest < Test::Unit::TestCase

  context "An EventTable" do
    setup do
      @head = Onfire::EventTable.new
    end
    
    should "return an empty array when it can't find handlers" do
      @head.add_handler :drink, :source_name => :stomach, :event_type => :thirsty
      
      assert_equal [], @head.handlers_for(    :hungry, :stomach)
      assert_equal [], @head.all_handlers_for(:hungry, :stomach)
    end
    
    should "return handlers in the same order as they were added" do
      @head.add_handler :drink,         :source_name => :stomach, :event_type => :hungry
      @head.add_handler :eat,           :source_name => :stomach, :event_type => :hungry
      @head.add_handler :sip,           :source_name => :mouth,   :event_type => :dry
      @head.add_handler :have_desert,                             :event_type => :hungry
      
      assert_equal [:sip], @head.handlers_for(:dry, :mouth)
      assert_equal [:sip], @head.all_handlers_for(:dry, :mouth)
      
      assert_equal [:drink, :eat], @head.handlers_for(:hungry, :stomach)
      assert_equal [:drink, :eat, :have_desert], @head.all_handlers_for(:hungry, :stomach)
    end
  end
end