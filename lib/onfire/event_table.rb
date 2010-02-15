module Onfire
  # Keeps all event handlers attached to one object.
  class EventTable
    attr_accessor :source2evt
    
    def initialize
      @source2evt = {}
    end
    
    def add_handler(handler, opts)
      event_type  = opts[:event_type]
      source_name   = opts[:source_name] || nil
      
      handlers_for(event_type, source_name) << handler
    end
    
    def add_handler_once(handler, opts)
      return if handlers_for(opts[:event_type], opts[:source_name]).include?(handler)
      
      add_handler(handler, opts)
    end
    
    def handlers_for(event_type, source_name=nil)
      evt_types = source2evt[source_name] ||= {}
      evt_types[event_type] ||= []
    end
    
    # Returns all handlers, even the catch-all.
    def all_handlers_for(event_type, source_name)
      handlers_for(event_type, source_name) + handlers_for(event_type, nil)
    end
  end
end
