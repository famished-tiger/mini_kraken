# frozen_string_literal: true

require 'singleton'
require_relative 'binary_relation'
require_relative '../composite/cons_cell_visitor'
require_relative 'duck_fiber'
require_relative 'log_var'
require_relative 'log_var_ref'

module MiniKraken
  module Core
    # equals tries to unify two terms
    class Equals < BinaryRelation
      include Singleton

      def initialize
        super('equals', '==')
      end

      # @param actuals [Array<Term>] A two-elements array
      # @param anEnv [Vocabulary] A vocabulary object
      # @return [Fiber<Outcome>] A Fiber(-like) instance that yields Outcomes
      def solver_for(actuals, anEnv)
        arg1, arg2 = *actuals
        DuckFiber.new(:custom) do
          outcome = unification(arg1, arg2, anEnv)
          outcome.prune!
        end
      end

      def unification(arg1, arg2, anEnv)
        arg1_nil = arg1.nil?
        arg2_nil = arg2.nil?
        if arg1_nil || arg2_nil
          if arg1_nil && arg2_nil
            result = Outcome.success(anEnv)
          else
            result = Outcome.failure(anEnv)
          end
          return result
        end
        new_arg1, new_arg2 = commute_cond(arg1, arg2, anEnv)
        do_unification(new_arg1, new_arg2, anEnv)
      end

      private


      # table: Unification
      # | arg1               | arg2               | Criterion                                 || Unification              |
      # | isa? Atomic        | isa? Atomic        | arg1.eq? arg2 is true                     || { "s", [] }              |
      # | isa? Atomic        | isa? Atomic        | arg1.eq? arg2 is false                    || { "u", [] }              |
      # | isa? CompositeTerm | isa? Atomic        | dont_care                                 || { "u", [] }              |
      # | isa? CompositeTerm | isa? CompositeTerm | unification(arg1.car, arg2.car) => "s"    || { "s", [bindings*] }     |
      # | isa? CompositeTerm | isa? CompositeTerm | unification(arg1.cdr, arg2.cdr) => "u"    || { "u", [] )              |             |
      # | isa? LogVarRef   | isa? Atomic        | arg1.fresh? is true                       || { "s", [arg2] }          |
      # | isa? LogVarRef   | isa? Atomic        | arg1.fresh? is false                      ||                          |
      # |                                         |   unification(arg1.value, arg2) => "s"    || { "s", [bindings*] }     |
      # |                                         |   unification(arg1.value, arg2) => "u"    || { "u", [] }              |
      # | isa? LogVarRef   | isa? CompositeTerm | arg1.fresh? is true                       || { "s", [arg2] }          |  # What if arg1 occurs in arg2?
      # | isa? LogVarRef   | isa? CompositeTerm | arg1.fresh? is false                      ||                          |
      # |                                         |   unification(arg1.value, arg2) => "s"    || { "s", [bindings*] }     |
      # |                                         |   unification(arg1.value, arg2) => "u"    || { "u", [] }              |
      # | isa? LogVarRef   | isa? LogVarRef   | arg1.fresh?, arg2.fresh? => [true, true]  || { "s", [arg1 <=> arg2] } |
      # | isa? LogVarRef   | isa? LogVarRef   | arg1.fresh?, arg2.fresh? => [true, false] ||                          |
      # |                                         |   unification(arg1, arg2.value) => "s"    || { "s", [bindings*] }     |
      # |                                         |   unification(arg1, arg2.value) => "u"    || { "u", [] }              |
      # | isa? LogVarRef   | isa? LogVarRef   | arg1.fresh?, arg2.fresh? => [false, false]||                          |
      # |                                         |   unification(arg1, arg2.value) => "s"    || { "s", [bindings*] }     |
      # |                                         |   unification(arg1, arg2.value) => "u"    || { "u", [] }
      def do_unification(arg1, arg2, anEnv)
        # require 'debug'
        return Outcome.success(anEnv) if arg1.equal?(arg2)

        result = Outcome.failure(anEnv) # default case

        if arg1.kind_of?(Atomic::AtomicTerm)
          result = Outcome.success(anEnv) if arg1.eql?(arg2)
        elsif arg1.kind_of?(Composite::CompositeTerm)
          if arg2.kind_of?(Composite::CompositeTerm) # Atomic::AtomicTerm is default case => fail
            result = unify_composite_terms(arg1, arg2, anEnv)
          end
        elsif arg1.kind_of?(LogVarRef)
          arg1_freshness = arg1.freshness(anEnv)
          if arg2.kind_of?(Atomic::AtomicTerm)
            if arg1_freshness.degree == :fresh
              result = Outcome.success(anEnv)
              arg1.associate(arg2, result)
            else
              result = Outcome.success(anEnv) if arg1.value(anEnv).eql?(arg2)
            end
          elsif arg2.kind_of?(Composite::CompositeTerm)
            if arg1_freshness.degree == :fresh
              result = Outcome.success(anEnv)
              arg1.associate(arg2, result)
            else
              # Ground case...
              arg1_associated = arg1_freshness.associated
              unless arg1_associated.kind_of?(Atomic::AtomicTerm)
                result = unify_composite_terms(arg1_associated, arg2, anEnv)
              end
            end
          elsif arg2.kind_of?(LogVarRef)
            freshness = [arg1.fresh?(anEnv), arg2.fresh?(anEnv)]
            case freshness
            when [false, false] # TODO: confirm this...
              result = unification(arg1.value(anEnv), arg2.value(anEnv), anEnv)
            when [true, true]
              result = Outcome.success(anEnv)
              if arg1.var_name != arg2.var_name
                arg1.associate(arg2, result)
                arg2.associate(arg1, result)
              end
            when [true, false]
              result = Outcome.success(anEnv)
              arg1.associate(arg2, result)
            else
              raise StandardError, "Unsupported freshness combination #{freshness}"
            end
          else
            arg_kinds = [arg1.class, arg2.class]
            raise StandardError, "Unsupported combination #{arg_kinds}"
          end
        end

        result
      end

      # @param arg1 [Composite::ConsCell]
      # @param arg2 [Composite::ConsCell]
      # @return [Outcome]
      def unify_composite_terms(arg1, arg2, anEnv)
        # require 'debug'
        result = Outcome.success(anEnv)
        # We'll do parallel iteration
        visitor1 = Composite::ConsCellVisitor.df_visitor(arg1)
        visitor2 = Composite::ConsCellVisitor.df_visitor(arg2)
        skip_children1 = false
        skip_children2 = false

        loop do
          side1, cell1 = visitor1.resume(skip_children1)
          side2, cell2 = visitor2.resume(skip_children2)
          if side1 != side2
            result = Outcome.failure(anEnv)
          elsif side1 == :stop
            break
          else
            case [cell1.class, cell2.class] # nil, Atomic::AtomicTerm, Composite::ConsCell, LogVarRef
              when [Composite::ConsCell, Composite::ConsCell]
                skip_children1 = false
                skip_children2 = false
              when [Composite::ConsCell, LogVarRef]
                skip_children1 = true
                skip_children2 = false
                sub_result = unification(cell1, cell2, anEnv)
                result = merge_results(result, sub_result)
              when [LogVarRef, Composite::ConsCell]
                skip_children1 = false
                skip_children2 = true
                sub_result = do_unification(cell1, cell2, anEnv)
                result = merge_results(result, sub_result)
            else
              skip_children1 = false
              skip_children2 = false
              sub_result = unification(cell1, cell2, anEnv)
              result = merge_results(result, sub_result)
            end
          end

          break if result.failure?
        end

        result
      end

      def merge_results(result1, result2)
        raise StandardError if result2.kind_of?(Hash)

        if result2.success?
          result1.merge(result2)
          result1
        else
          result2
        end
      end
    end # class

    Equals.instance.freeze
  end # module
end # module
