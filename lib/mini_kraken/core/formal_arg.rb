# frozen_string_literal: true

module MiniKraken
  module Core
    # The generalization of any iem that can be
    # passed as arugement to a goal.
    class FormalArg
      # @return [String]
      attr_reader :name

      def initialize(aName)
        @name = validated_name(aName)
      end

      private

      def validated_name(aName)
        aName
      end
    end # class
  end # module
end # module
