require_relative 'composite_term'

module MiniKraken
  module Core
    class ConsCell < CompositeTerm
      attr_reader :car
      attr_reader :cdr

      def initialize(obj1, obj2 = nil)
        @car = obj1
        @cdr = obj2
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
    end # class

    # Constant representing the null (empty) list.
    NullList = ConsCell.new(nil, nil).freeze
  end # module
end # module