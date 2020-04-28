require_relative '../../lib/mini_kraken/core/any_value'
require_relative '../../lib/mini_kraken/core/cons_cell'
require_relative '../../lib/mini_kraken/core/k_symbol'
require_relative '../../lib/mini_kraken/core/variable'
require_relative '../../lib/mini_kraken/core/variable_ref'

module MiniKraken
  # Mix-in module that provides convenience factory methods.
  module FactoryMethods
    # Factory method for constructing an AnyValue instance
    # @param rank [Integer]
    # @return [Core::AnyValue]
    def any_value(rank)
      Core::AnyValue.new(rank)
    end

    # Factory method for constructing a ConsCell
    # @param obj1 [Term]
    # @param obj2 [Term]    
    # @return [Core::ConsCell]    
    def cons(obj1, obj2 = nil)
      Core::ConsCell.new(obj1, obj2)
    end

    # Factory method for constructing a goal using the Equals relation.
    # @param arg1 [Term]
    # @param arg2 [Term]    
    # @return [Core::Goal]     
    def equals_goal(arg1, arg2)
      Core::Goal.new(Core::Equals.instance, [arg1, arg2])
    end

    # Factory method for constructing a KSymbol instance
    # @param aSymbol [Symbol]
    # @return [Core::KSymbol]    
    def k_symbol(aSymbol)
      Core::KSymbol.new(aSymbol)
    end
    
    # Factory method for constructing a Variable
    # @param var_name [String]
    # @return [Core::Variable]    
    def var_ref(var_name)
      Core::Variable.new(var_name)
    end
    
    # Factory method for constructing a VariableRef
    # @param var_name [String]
    # @return [Core::VariableRef]    
    def var_ref(var_name)
      Core::VariableRef.new(var_name)
    end
  end # end
end # module