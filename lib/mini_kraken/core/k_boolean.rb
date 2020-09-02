# frozen_string_literal: true

require_relative 'atomic_term'

module MiniKraken
  module Core
    # A specialized atomic term that represents an boolean (true/false) value.
    # in MiniKraken
    class KBoolean < AtomicTerm
      # @param aValue [Boolean, Symbol] Ruby representation of boolean value
      def initialize(aValue)
        super(validated_value(aValue))
      end

      def to_s
        value.to_s
      end

      private

      def validated_value(aValue)
        case aValue
          when true, false
            aValue
          when :"#t", '#t'
            true
          when :"#f", '#f'
            false
          else
            raise StandardError, "Invalid boolean literal '#{aValue}'"
        end
      end
    end # class
  end # module
end # module
