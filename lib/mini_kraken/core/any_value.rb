module MiniKraken
  module Core
    class AnyValue
      attr_reader :rank
      
      # @param aName [String]
      # @param anEnv [Vocabulary]
      def initialize(aName, anEnv, alternate_names = [])
        @rank = anEnv.get_rank(aName, alternate_names)
      end
      
      def ==(other)
        rank == other.rank
      end
      
      # Use same text representation as in Reasoned Schemer.
      def to_s
        "_#{rank}"
      end
      
      def ground?(_env)
        false
      end
      
      # @return [AnyValue]
      def quote(_env)
        self
      end      
    end # class
  end # module
end # module