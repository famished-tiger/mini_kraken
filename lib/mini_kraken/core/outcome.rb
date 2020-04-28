require_relative 'vocabulary'

module MiniKraken
  module Core
    class Outcome
      include Vocabulary # Use mix-in module

      # @return [Symbol] One of: :"#s" (success), :"#u" (failure)
      attr_reader :resultant

      def initialize(aResult, aParent = nil)
        init_vocabulary(aParent)
        @resultant = aResult
      end

      def successful?
        self.resultant == :"#s"
      end

      def ==(other)
        are_equal = false

        if resultant == other.resultant && parent == other.parent &&
          associations == other.associations
          are_equal = true
        end

        are_equal
      end
    end # class

    Failure = Outcome.new(:"#u")
    BasicSuccess = Outcome.new(:"#s")
  end # module
end # module