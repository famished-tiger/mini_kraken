require_relative 'relation'

module MiniKraken
  module Core
    class NullaryRelation < Relation
      def initialize(aName)
        super(aName)
        @tuple.freeze
      end
    end # class
  end # module
end # module