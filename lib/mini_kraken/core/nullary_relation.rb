# frozen_string_literal: true

require_relative 'relation'

module MiniKraken
  module Core
    class NullaryRelation < Relation
      # @param aName [String] Name of the relation.
      # @param alternateName [String, NilClass] Alternative name (optional).
      def initialize(aName, alternateName = nil)
        super(aName, alternateName)
        freeze
      end

      # Number of arguments for the relation.
      # @return [Integer]
      def arity
        0
      end
    end # class
  end # module
end # module
