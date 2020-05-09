# frozen_string_literal: true

module MiniKraken
  module Core
    class Relation
      # @return [String] Name of the relation.
      attr_reader :name

      # @return [String, NilClass] Optional alternative name of the relation.
      attr_reader :alt_name

      # @param aName [String] Name of the relation.
      # @param alternateName [String, NilClass] Alternative name (optional).
      def initialize(aName, alternateName = nil)
        @name = aName
        @alt_name = alternateName
      end

      # Number of arguments for the relation.
      # @return [Integer]
      def arity
        raise NotImplementedError
      end

      def inspect
        alt_name || name
      end
    end # class
  end # module
end # module
