# frozen_string_literal: true

require_relative 'composite_term'

unless MiniKraken::Core.constants(false).include? :ConsCell
  module MiniKraken
    module Core
      class ConsCell < CompositeTerm
        attr_reader :car
        attr_reader :cdr

        def initialize(obj1, obj2 = nil)
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
        def null?
          car.nil? && cdr.nil?
        end

        def ==(other)
          return false unless other.respond_to?(:car)

          (car == other.car) && (cdr == other.cdr)
        end

        def eql?(other)
          (self.class == other.class) && car.eql?(other.car) && cdr.eql?(other.cdr)
        end

        def quote(anEnv)
          return self if null?

          new_car = car.nil? ? nil : car.quote(anEnv)
          new_cdr = cdr.nil? ? nil : cdr.quote(anEnv)
          ConsCell.new(new_car, new_cdr)
        end

        # Use the list notation from Lisp as a text representation.
        def to_s
          return '()' if null?

          "(#{pair_to_s})"
        end

        def append(another)
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
end # defined
