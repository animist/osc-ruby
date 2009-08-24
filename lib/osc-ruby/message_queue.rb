module OSC
  class MessageQueue 
    
    def initialize
      @queue = []
      @monitor = Monitor.new
      @empty_cond = @monitor.new_cond
      
    end
    
    def push( item )
      @monitor.synchronize do
        @queue.push( item )
        @empty_cond.signal
      end
    end

    
    def pop_event
      @monitor.synchronize do
        
        @empty_cond.wait_while { @queue.empty? }
      
        @queue = @queue.sort do |a, b| 
          (b.time || Time.now) <=> ( a.time || Time.now )
        end
        
        message = @queue.pop
        	      
	      @empty_cond.wait_while do
  	      (( message.time || 0 ) - Time.now.to_ntp ) > 0
        end
        
        message
      end
    end
  end
end