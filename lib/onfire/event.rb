module Onfire
  # An Event is born in #fire and is passed up the ancestor chain of the triggering datastructure.
  # It carries a <tt>type</tt>, the fireing widget <tt>source</tt> and arbitrary payload <tt>data</tt>.
  class Event
    
    attr_accessor :type, :source, :data
    
    def initialize(type=nil, source=nil, data=nil)
      @type       = type
      @source     = source
      @data       = data
    end
    
    def stopped?
      @stopped ||= false
    end
    
    # Stop event bubbling.
    def stop!
      @stopped = true
    end
    
    def bubble!
      node = source
      # in a real visitor pattern, the visited would call #process_node.
      begin process_node(node) end while node = node.parent
    end
    
    def process_node(node) # usually called #visit.
      node.handlers_for_event(self).each do |proc|
        return if stopped?
        call_handler(proc)
      end
    end
    
    def call_handler(proc)
      proc.call(self)
    end
  end
end
