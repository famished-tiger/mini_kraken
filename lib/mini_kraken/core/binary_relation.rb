require_relative 'relation'
require_relative 'composite_term'

module MiniKraken
  module Core
    class BinaryRelation < Relation
      # @param aName [String] Name of the relation.
      # @param alternateName [String, NilClass] Alternative name (optional).    
      def initialize(aName, alternateName = nil)
        super(aName, alternateName)
        freeze
      end
      
      # Number of arguments for the relation.
      # @return [Integer]
      def arity
        2
      end
      
      protected
      
      # table: Commute
      # |arg1                | arg2               | arg2.ground? || Commute |
      # | isa? Atomic        | isa? Atomic        | dont_care    || Yes     |
      # | isa? Atomic        | isa? CompositeTerm | dont_care    || Yes     |
      # | isa? Atomic        | isa? VariableRef   | dont_care    || Yes     |
      # | isa? CompositeTerm | isa? Atomic        | true         || No      |
      # | isa? CompositeTerm | isa? CompositeTerm | false        || Yes     |
      # | isa? CompositeTerm | isa? CompositeTerm | true         || No      |
      # | isa? CompositeTerm | isa? VariableRef   | dont_care    || Yes     |
      # | isa? VariableRef   | isa? Atomic        | dont_care    || No      |
      # | isa? VariableRef   | isa? CompositeTerm | dont_care    || No      |
      # | isa? VariableRef   | isa? VariableRef   | false        || Yes     |
      # | isa? VariableRef   | isa? VariableRef   | true         || No      |
      def commute_cond(arg1, arg2, env)
        commuting = true
        arg2_is_var_ref = arg2.kind_of?(VariableRef)

        if arg1.kind_of?(CompositeTerm)
          if arg2_is_var_ref
            commuting = true
          else
            commuting = !arg2.ground?(env)
          end
        elsif arg1.kind_of?(VariableRef)
          if arg2_is_var_ref
            commuting = !arg2.ground?(env)
          else
            commuting = false
          end
        end

        if commuting
          [arg2, arg1]
        else
          [arg1, arg2]
        end
      end      
    end # class
  end # module
end # module