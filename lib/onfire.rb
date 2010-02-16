require 'onfire/event'
require 'onfire/event_table'

module Onfire
  def on(event_type, options={}, &block)
    table_options = {}
    table_options[:event_type]  = event_type
    table_options[:source_name] = options[:from] if options[:from]
    
    if block_given?
      attach_event_handler(block, table_options)
    end
  end
  
  def fire(event_type)
    bubble_event Event.new(event_type, self)
  end
  
  def process_event(event)
    local_handlers = event_table.all_handlers_for(event.type, event.source.name)
    
    local_handlers.each do |proc|
      proc.call(event)
    end
  end
  
  def bubble_event(event)
    process_event(event) # locally process event, then climb up.
    return if root?
    
    parent.bubble_event(event)
  end
  
  def root?
    !parent
  end
  
  protected
    def event_table
      @event_table ||= Onfire::EventTable.new
    end
    
    def attach_event_handler(proc, table_options)
      event_table.add_handler(proc, table_options)
    end
    
end