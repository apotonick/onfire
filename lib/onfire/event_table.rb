module Onfire
  # Keeps all event handlers attached to one object.
  class EventTable
    attr_accessor :source2evt
    
    def initialize
      @source2evt = {}
    end
    
    def add_handler(handler, opts)
      event_type    = opts[:event_type]
      source_name   = opts[:from] || nil
      
      handlers_for(event_type, source_name) << handler
    end
    
    def handlers_for(event_type, source_name=nil)
      evt_types = source2evt[source_name] ||= {}
      evt_types[event_type] ||= []
    end
    
    # Returns all handlers, with :from first, then catch-all.
    def all_handlers_for(event_type, source_name)
      handlers_for(event_type, source_name) + handlers_for(event_type, nil)
    end
  end
end
