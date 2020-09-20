# frozen_string_literal: true

require_relative 'composite_term'

module MiniKraken
  module Composite
    # In Lisp dialects, a cons cell (or a pair) is a data structure with two
    # fields called the car and cdr fields (for historical reasons).
    # Cons cells are the key ingredient for building lists in Lisp.
    # A cons cell can be depicted as a box with two parts, car and cdr each
    # containing a reference to another object.
    #   +-----------+
    #   | car | cdr |
    #   +--|-----|--+
    #      |     |
    #      V     V
    #     obj1  obj2
    #
    # The list (1 2 3) can be constructed as follows:
    #   +-----------+
    #   | car | cdr |
    #   +--|-----|--+
    #      |     |
    #      V     V
    #      1  +-----------+
    #         | car | cdr |
    #         +--|-----|--+
    #            |     |
    #            V     V
    #            2  +-----------+
    #               | car | cdr |
    #               +--|-----|--+
    #                  |     |
    #                  V     V
    #                  3    nil
    class ConsCell < CompositeTerm
      # The first slot in a ConsCell
      # @return [Term]
      attr_reader :car

      # The second slot in a ConsCell
      # @return [Term]
      attr_reader :cdr

      # Construct a new conscell whose car and cdr are obj1 and obj2.
      # @param obj1 [Term, NilClass]
      # @param obj2 [Term, NilClass]
      def initialize(obj1, obj2 = nil)
        super()
        @car = obj1
        if obj2.kind_of?(ConsCell) && obj2.null?
          @cdr = nil
        else
          @cdr = obj2
        end
      end

      def children
        [car, cdr]
      end

      # Return true if it is an empty list, otherwise false.
      # A list is empty, when both car and cdr fields are nil.
      # @return [Boolean]
      def null?
        car.nil? && cdr.nil?
      end

      # Return true if car and cdr fields have the same values as the other 
      # ConsCell.
      # @param other [ConsCell]
      # @return [Boolean]
      def ==(other)
        return false unless other.respond_to?(:car)

        (car == other.car) && (cdr == other.cdr)
      end
      
      # Test for type and data value equality.
      # @param other [ConsCell]
      # @return [Boolean]      
      def eql?(other)
        (self.class == other.class) && car.eql?(other.car) && cdr.eql?(other.cdr)
      end

      # Return a data object that is a copy of the ConsCell
      # @param anEnv [Core::Environment]
      # @return [ConsCell]      
      def quote(anEnv)
        return self if null?

        new_car = car.nil? ? nil : car.quote(anEnv)
        new_cdr = cdr.nil? ? nil : cdr.quote(anEnv)
        ConsCell.new(new_car, new_cdr)
      end

      # Use the list notation from Lisp as a text representation.
      # @return [String]
      def to_s
        return '()' if null?

        "(#{pair_to_s})"
      end

      # Change the cdr of ConsCell to 'another'.
      # Analogue of set-cdr! procedure in Scheme.
      # @param another [Term]
      def set_cdr!(another)
        @cdr = another
      end

      protected

      def pair_to_s
        result = +car.to_s
        if cdr
          result << ' '
          if cdr.kind_of?(ConsCell)
            result << cdr.pair_to_s
          else
            result << ". #{cdr}"
          end
        end

        result
      end
    end # class

    # Constant representing the null (empty) list.
    NullList = ConsCell.new(nil, nil).freeze
  end # module
end # module
