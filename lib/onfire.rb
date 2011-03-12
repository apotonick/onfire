require 'onfire/event'
require 'onfire/event_table'

module Onfire
  # Attachs an event observer to the receiver which is called by a matching event.
  #
  # The handler might be a block receiving the triggering event.
  #
  #   matz.on :applaus do |evt|
  #     puts "grin"
  #   end
  #
  # You can also pass a callable object as handler.
  #
  #   class GrinHandler
  #     def call(evt)
  #       puts "grin"
  #     end
  #   end
  #
  #   matz.on :applaus, :do => GrinHandler.new
  #
  # The +:from+ option allows conditional filtering.
  # 
  #   matz.on :applaus, :from => audience do |evt|
  #
  # This handler is called only if +audience+ trigger the +:applaus+ event.
  def on(event_type, options={}, &block)
    options[:event_type] = event_type
    
    event_table.add_handler(block || options[:call], options)
  end
  
  # Fires an event which will bubble up starting from the receiver. While bubbling,
  # the events checks the traversed object for matching observers and calls the handlers
  # in the order they were attached.
  #
  # Notice that you can append payload data to the event object.
  #    
  #   fire :click, :time => Time.now
  #
  # The payload is accessable in the +data+ attribute.
  #
  #   evt.data[:time] # => 2011-03-12 11:25:57 +0100
  def fire(event_type, data={})
    event_for(event_type, self, data).bubble!
  end
  
  def event_table
    @event_table ||= Onfire::EventTable.new
  end
  
  # Get all handlers from self for the passed event (interface for Event).
  def handlers_for_event(event)
    event_table.all_handlers_for(event.type, event.source)
  end
  
protected
  # Factory method for creating the event. Override if you want your own event.
  def event_for(*args)
    Event.new(*args)
  end
end
