# frozen_string_literal: true

require_relative '../core/term'
require_relative '../core/freshness'

module MiniKraken
  # This module packages the atomic term classes, that is,
  # the basic MiniKraken datatypes.
  module Atomic
    # An atomic term is an elementary MiniKraken term, a data value
    # that cannot be decomposed into simpler MiniKraken term(s).
    # Typically, an atomic term encapsulates a Ruby primitive data object.
    # MiniKraken treats atomic terms as immutable objects.
    class AtomicTerm < Core::Term
      # @return [Object] Internal representation of a MiniKraken data value.
      attr_reader :value

      # Initialize an atomic term with the given data object.
      # @param aValue [Object] Ruby representation of MiniKraken data value
      def initialize(aValue)
        super()
        @value = aValue
        @value.freeze
      end

      # An atomic term is by definition a ground term: since it doesn't contain
      # any bound variable (in Prolog sense).
      # @param _env [Vocabulary]
      # @return [Freshness]
      def freshness(_env)
        Core::Freshness.new(:ground, self)
      end

      # An atomic term is a ground term: by definition it doesn't contain
      # any fresh variable.
      # @param _env [Vocabulary]
      # @return [FalseClass]
      def fresh?(_env)
        false
      end

      # An atomic term is a ground term: by definition it doesn't contain
      # any (fresh) variable.
      # @param _env [Vocabulary]
      # @return [TrueClass]
      def ground?(_env)
        true
      end

      # Return a String representation of the atomic term
      # @return [String]
      def to_s
        value.to_s
      end

      # Treat this object as a data value.
      # @return [AtomicTerm]
      def quote(_env)
        self
      end

      # Data equality testing
      # @param other [AtomicTerm, #value]
      # @return [Boolean]
      def ==(other)
        if other.respond_to?(:value)
          value == other.value
        else
          value == other
        end
      end

      # Type and data equality testing
      # @param other [AtomicTerm]
      # @return [Boolean]
      def eql?(other)
        (self.class == other.class) && value.eql?(other.value)
      end
    end # class
  end # module
end # module
