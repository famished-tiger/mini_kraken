module MiniKraken
  module Core
    class Relation
      attr_reader :name
      attr_reader :tuple

      def initialize(aName)
        @name = aName
        @tuple = []
      end

      def arity
        tuple.size
      end
    end # class
  end # module
end # module