# frozen_string_literal: true

require_relative 'base_arg'

module MiniKraken
  module Core
    # A formal reference represents the occurrence of a formal argument name in a
    # goal template argument list.
    class FormalRef < BaseArg
      # @return [String] The name of a formal argument.
      attr_reader :name

      def initialize(aName)
        super()
        @name = validated_name(aName)
      end

      private

      def validated_name(aName)
        aName
      end
    end # class
  end # module
end # module
