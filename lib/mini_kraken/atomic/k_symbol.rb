# frozen_string_literal: true

require_relative 'atomic_term'

module MiniKraken
  module Atomic
    # A specialized atomic term that represents a symbolic value
    # in MiniKraken.
    class KSymbol < AtomicTerm
      # Returns the name or string corresponding to value.
      # @return [String]
      def id2name
        value.id2name
      end

      # Returns a string representing the MiniKraken symbol.
      # @return [String]
      def to_s
        ":#{id2name}"
      end
    end # class
  end # module
end # module
