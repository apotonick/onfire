require 'onfire/event'
require 'onfire/event_table'

module Onfire
  def on(event_type, options={}, &block)
    table_options = {}
    table_options[:event_type]  = event_type
    table_options[:source_name] = options[:from] if options[:from]
    
    if block_given?
      return attach_event_handler(block, table_options)
    end
    
    attach_event_handler(options[:do], table_options)
  end
  
  def fire(event_type, data={})
    bubble_event event_for(event_type, self, data)
  end
  
  def bubble_event(event)
    process_event(event) # locally process event, then climb up.
    return if root?
    
    parent.bubble_event(event)
  end
  
  def process_event(event)
    local_event_handlers(event).each do |proc|
      return if event.stopped?
      proc.call(event)
    end
  end
  
  def root?
    !parent
  end
  
  def event_table
    @event_table ||= Onfire::EventTable.new
  end
    
protected
  def attach_event_handler(proc, table_options)
    event_table.add_handler(proc, table_options)
  end
  
  # Get all handlers from self for the passed event.
  def local_event_handlers(event)
    event_table.all_handlers_for(event.type, event.source)
  end
  
  # Factory method for creating the event. Override if you want your own event.
  def event_for(*args)
    Event.new(*args)
  end
end
