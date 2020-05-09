# frozen_string_literal: true

require_relative 'term'
require_relative 'freshness'

module MiniKraken
  module Core
    # An atomic term is an elementary Minikraken term that cannot be
    # decomposed into simpler MiniKraken data value(s).
    class AtomicTerm < Term
      # @return [Object] Internal representation of a MiniKraken data value
      attr_reader :value

      # @param aValue [Object] Ruby representation of MiniKraken data value
      def initialize(aValue)
        @value = aValue
        @value.freeze
      end

      # An atomic term is by definition a ground term: since it doesn't contain
      # any bound variable (in Prolog sense).
      # @param _env [Vocabulary]
      # @return [Freshness]
      def freshness(_env)
        Freshness.new(:ground, self)
      end

      # An atomic term is a ground term: by definition it doesn't contain
      # any fresh variable.
      # @param _env [Vocabulary]
      # @return [FalseClass]
      def fresh?(_env)
        false
      end

      # An atomic term is a ground term: by definition it doesn't contain
      # any fresh variable.
      # @param _env [Vocabulary]
      # @return [TrueClass]
      def ground?(_env)
        true
      end

      # @return [AtomicTerm]
      def quote(_env)
        self
      end

      # Data equality testing
      # @return [Boolean]
      def ==(other)
        if other.respond_to?(:value)
          value == other.value
        else
          value == other
        end
      end

      # Type and data equality testing
      # @return [Boolean]
      def eql?(other)
        (self.class == other.class) && value.eql?(other.value)
      end
    end # class
  end # module
end # module
