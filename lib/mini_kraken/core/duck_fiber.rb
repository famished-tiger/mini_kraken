require_relative 'outcome'

module MiniKraken
  module Core
    # A mock class that mimicks the behavior of a Fiber instance.
    class DuckFiber
      # @return [Outcome] The sole outcome to yield.
      attr_reader :outcome

      # @return [Symbol] one of: :initial, :yielded
      attr_reader :state

      # @param outcomeKind [Symbol] One of: :failure, :basic_success, :custom
      def initialize(outcomeKind, &customization)
        @state = :initial
        if outcomeKind == :custom && block_given?
          @outcome = customization.call
        else
          @outcome = valid_outcome(outcomeKind)
        end
      end

      def resume(*_args)
        if state == :initial
          @state = :yielded
          return outcome
        else
          return nil
        end
      end
      
      def valid_outcome(outcomeKind)
        case outcomeKind
          when :failure
            Failure
          when :success
            BasicSuccess
          else
            raise StandardError, "Unknonw outcome kind #{outcomeKind}"
        end
      end
    end # class
  end # module
end # module
