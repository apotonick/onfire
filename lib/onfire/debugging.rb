module Onfire
  class Event
    module Debugging
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        # Blocks added with #debug are executed on every node while traversing up.
        #
        #   Event.debug do |node, evt|
        #     puts "traversing #{node}"
        #   end
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
      
      # Currently unused.
      def call_handler(proc, node)
        super
      end
    end
  end
end
