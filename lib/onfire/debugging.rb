module Onfire
  class Event
    module Debugging
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def debug(&block)
          debug_blocks << block
        end
        
        def debug_blocks
          @debug_blocks ||= []
        end
      end
      
      def process_node(node)
        self.class.debug_blocks.each do |debugger|
          debugger.call(node, self, node.handlers_for_event(self))
        end
        
        super
      end
      
      
      def call_handler(proc, node)
        super
      end
    end
  end
  
  module Debugging
  end
end
