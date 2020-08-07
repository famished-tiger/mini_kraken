# frozen_string_literal: true

require 'singleton'
require_relative 'binary_relation'
# require_relative 'any_value'
require_relative 'duck_fiber'
require_relative 'variable'
require_relative 'variable_ref'

unless MiniKraken::Core.constants(false).include? :Equals
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
          DuckFiber.new(:custom) { unification(arg1, arg2, anEnv) }
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
        # | isa? VariableRef   | isa? Atomic        | arg1.fresh? is true                       || { "s", [arg2] }          |
        # | isa? VariableRef   | isa? Atomic        | arg1.fresh? is false                      ||                          |
        # |                                         |   unification(arg1.value, arg2) => "s"    || { "s", [bindings*] }     |
        # |                                         |   unification(arg1.value, arg2) => "u"    || { "u", [] }              |
        # | isa? VariableRef   | isa? CompositeTerm | arg1.fresh? is true                       || { "s", [arg2] }          |  # What if arg1 occurs in arg2?
        # | isa? VariableRef   | isa? CompositeTerm | arg1.fresh? is false                      ||                          |
        # |                                         |   unification(arg1.value, arg2) => "s"    || { "s", [bindings*] }     |
        # |                                         |   unification(arg1.value, arg2) => "u"    || { "u", [] }              |
        # | isa? VariableRef   | isa? VariableRef   | arg1.fresh?, arg2.fresh? => [true, true]  || { "s", [arg1 <=> arg2] } |
        # | isa? VariableRef   | isa? VariableRef   | arg1.fresh?, arg2.fresh? => [true, false] ||                          |
        # |                                         |   unification(arg1, arg2.value) => "s"    || { "s", [bindings*] }     |
        # |                                         |   unification(arg1, arg2.value) => "u"    || { "u", [] }              |
        # | isa? VariableRef   | isa? VariableRef   | arg1.fresh?, arg2.fresh? => [false, false]||                          |
        # |                                         |   unification(arg1, arg2.value) => "s"    || { "s", [bindings*] }     |
        # |                                         |   unification(arg1, arg2.value) => "u"    || { "u", [] }
        def do_unification(arg1, arg2, anEnv)
          # require 'debug'
          return Outcome.success(anEnv) if arg1.equal?(arg2)

          result = Outcome.failure(anEnv) # default case

          if arg1.kind_of?(AtomicTerm)
            result = Outcome.success(anEnv) if arg1.eql?(arg2)
          elsif arg1.kind_of?(CompositeTerm)
            if arg2.kind_of?(CompositeTerm) # AtomicTerm is default case => fail
              result = unify_composite_terms(arg1, arg2, anEnv)
            end
          elsif arg1.kind_of?(VariableRef)
            arg1_freshness = arg1.freshness(anEnv)
            if arg2.kind_of?(AtomicTerm)
              if arg1_freshness.degree == :fresh
                result = Outcome.success(anEnv)
                arg1.associate(arg2, result)
              else
                result = Outcome.success(anEnv) if arg1.value(anEnv).eql?(arg2)
              end
            elsif arg2.kind_of?(CompositeTerm)
              if arg1_freshness.degree == :fresh
                result = Outcome.success(anEnv)
                arg1.associate(arg2, result)
              else
                # Ground case...
                result = unify_composite_terms(arg1_freshness.associated, arg2, anEnv)
              end
            elsif arg2.kind_of?(VariableRef)
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

        # @return [Freshness]
        def unify_composite_terms(arg1, arg2, anEnv)
          # require 'debug'
          result = Outcome.failure(anEnv)
          children1 = arg1.children
          children2 = arg2.children

          if children1.size == children2.size
            i = 0
            subresults = children1.map do |child1|
              child2 = children2[i]
              i += 1
              unification(child1, child2, anEnv)
            end
            total_success = subresults.all?(&:successful?)
            if total_success
              memo = Outcome.success(anEnv)
              subresults.reduce(memo) do |sub_total, outcome|
                sub_total.merge(outcome)
                sub_total
              end
              result = memo
            end
          end

          result
        end
      end # class

      Equals.instance.freeze
    end # module
  end # module
end # unless
