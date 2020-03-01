module MiniKraken
  module Core
    class Publisher
      attr_reader :subscribers

      def initialize
        @subscribers = []
      end
      
      def subscribe(aListener)
        @subscribers << aListener
      end
      
      def broadcast_entry(aGoal, variables)
        subscribers.each do |subscr|
          subscr.on_entry(aGoal, variables)
        end
      end
      
      def broadcast_exit(aGoal, variables, outcome)
        subscribers.each do |subscr|
          subscr.on_exit(aGoal, variables, outcome)
        end      
      end      
    end # class
  end # module
end # module