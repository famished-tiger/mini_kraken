module MiniKraken
  module Core
    class Variable
      attr_reader :name
      
      def initialize(aName)
        @name = aName
      end
    end # class
  end # module
end # module