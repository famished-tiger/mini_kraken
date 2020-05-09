# frozen_string_literal: true

module MiniKraken
  module Core
    # A record that a given vairable is associated with a value.
    class Association
      # @return [String] internal name of variable being associated the value.
      attr_accessor :i_name

      # @return [Term] the MiniKraken value associated with the variable
      attr_reader :value


      # @param aVariable [Variable, String] A variable or its name.
      # @param aValue [Term] value being associated to the variable.
      def initialize(aVariable, aValue)
        a_name = aVariable.respond_to?(:name) ? aVariable.i_name : aVariable
        @i_name = validated_name(a_name)
        @value = aValue
      end

      private

      def validated_name(aName)
        raise StandardError, 'Name cannot be nil' if aName.nil?

        cleaned = aName.strip
        raise StandardError, 'Name cannot be empty or consists of spaces' if cleaned.empty?

        cleaned
      end
    end # class
  end # module
end # module
