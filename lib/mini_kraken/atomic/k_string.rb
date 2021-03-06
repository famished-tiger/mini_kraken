# frozen_string_literal: true

require_relative 'atomic_term'

module MiniKraken
  module Atomic
    # A specialized atomic term that represents a string value
    # in MiniKraken.
    class KString < AtomicTerm
      # Returns a string representing the MiniKraken symbol.
      # @return [String]
      def to_s
        value
      end
    end # class
  end # module
end # module
