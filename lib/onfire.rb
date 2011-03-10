require 'onfire/event'
require 'onfire/event_table'

module Onfire
  def on(event_type, options={}, &block)
    options[:event_type] = event_type
    
    if block_given?
      event_table.add_handler(proc, options) and return
    end
    
    event_table.add_handler(options[:do], options)
  end
  
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
