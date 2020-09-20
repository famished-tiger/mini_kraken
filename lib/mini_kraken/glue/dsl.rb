# frozen_string_literal: true

require 'set'
require_relative '../atomic/all_atomic'
require_relative '../core/any_value'
require_relative '../core/conde'
require_relative '../core/conj2'
require_relative '../composite/cons_cell'
require_relative '../core/def_relation'
require_relative '../core/disj2'
require_relative '../core/equals'
require_relative '../core/fail'
require_relative '../core/formal_arg'
require_relative '../core/formal_ref'
require_relative '../glue/fresh_env'
require_relative '../glue/fresh_env_factory'
require_relative '../core/goal_template'
require_relative '../core/succeed'
require_relative '../core/tap'
require_relative '../core/log_var_ref'
require_relative 'fresh_env'
require_relative 'run_star_expression'


module MiniKraken
  module Glue
    # The mixin module that implements the methods for the DSL
    # (DSL = Domain Specific Langague) that allows MiniKraken
    # users to embed Minikanren in their Ruby code.
    module DSL
      # A run* expression tries to find all the solutions
      # that meet the given goal.
      # @return [Composite::ConsCell] A list of solutions
      def run_star(var_names, goal)
        program = RunStarExpression.new(var_names, goal)
        program.run
      end

      def conde(*goals)
        # require 'debug'
        args = goals.map do |goal_maybe|
          if goal_maybe.kind_of?(Array)
            goal_maybe.map { |g| convert(g) }
          else
            convert(goal_maybe)
          end
        end

        Core::Goal.new(Core::Conde.instance, args)
      end

      # conj2 stands for conjunction of two arguments.
      # Returns a goal linked to the Core::Conj2 relation.
      # The rule of that relation succeeds when both arguments succeed.
      # @param arg1 [Core::Goal]
      # @param arg2 [Core::Goal]
      # @return [Core::Failure|Core::Success]
      def conj2(arg1, arg2)
       goal_class.new(Core::Conj2.instance, [convert(arg1), convert(arg2)])
      end

      def cons(car_item, cdr_item = nil)
        tail = cdr_item.nil? ? cdr_item : convert(cdr_item)
        Composite::ConsCell.new(convert(car_item), tail)
      end

      def defrel(relationName, theFormals, &aGoalTemplateExpr)
        start_defrel

        case theFormals
          when String
            @defrel_formals << theFormals
          when Array
            @defrel_formals.merge(theFormals)
        end

        formals = @defrel_formals.map { |name| Core::FormalArg.new(name) }
        g_template = aGoalTemplateExpr.call
        result = Core::DefRelation.new(relationName, g_template, formals)
        add_defrel(result)

        end_defrel
        result
      end

      def disj2(arg1, arg2)
        goal_class.new(Core::Disj2.instance, [convert(arg1), convert(arg2)])
      end

      # @return [Core::Fail] A goal that unconditionally fails.
      def _fail
        goal_class.new(Core::Fail.instance, [])
      end

      def equals(arg1, arg2)
        # require 'debug'
        goal_class.new(Core::Equals.instance, [convert(arg1), convert(arg2)])
      end

      def fresh(var_names, goal)
        vars = nil
        if @dsl_mode == :defrel
          if var_names.kind_of?(String)
            vars = [var_names]
          else
            vars = var_names
          end
          FreshEnvFactory.new(vars, goal)
        else
          if var_names.kind_of?(String) || var_names.kind_of?(Core::LogVarRef)
            vars = [var_names]
          else
            vars = var_names
          end

          FreshEnv.new(vars, goal)
        end
      end

      def list(*members)
        return null if members.empty?

        head = nil
        members.reverse_each { |elem| head = Composite::ConsCell.new(convert(elem), head) }

        head
      end

      # @return [ConsCell] Returns an empty list, that is, a pair whose members are nil.
      def null
        Composite::ConsCell.new(nil, nil)
      end

      # @return [Core::Succeed] A goal that unconditionally succeeds.
      def succeed
        goal_class.new(Core::Succeed.instance, [])
      end

      def tap(arg1)
        goal_class.new(Core::Tap.instance, [convert(arg1)])
      end

      private

      def convert(anArgument)
        converted = nil

        case anArgument
          when Symbol
            if anArgument.id2name =~ /_\d+/
              rank = anArgument.id2name.slice(1..-1).to_i
              any_val = Core::AnyValue.allocate
              any_val.instance_variable_set(:@rank, rank)
              converted = any_val
            elsif anArgument.id2name =~ /^"#[ft]"$/
              converted = Atomic::KBoolean.new(anArgument)
            else
              converted = Atomic::KSymbol.new(anArgument)
            end
          when String
            if anArgument =~ /^#[ft]$/
              converted = Atomic::KBoolean.new(anArgument)
            else
              msg = "Internal error: undefined conversion for #{anArgument.class}"
              raise StandardError, msg
            end
          when false, true
            converted = Atomic::KBoolean.new(anArgument)
          when Atomic::KBoolean, Atomic::KSymbol
            converted = anArgument
          when Core::FormalRef
            converted = anArgument
          when FreshEnv
            converted = anArgument
          when Core::Goal
            converted = anArgument
          when Core::GoalTemplate
            converted = anArgument
          when Core::LogVarRef
            converted = anArgument
          when Composite::ConsCell
            converted = anArgument
          else
            msg = "Internal error: undefined conversion for #{anArgument.class}"
            raise StandardError, msg
        end

        converted
      end

      def default_mode
        @dsl_mode = :default
        @defrel_formals = nil
      end

      def goal_class
        default_mode unless instance_variable_defined?(:@dsl_mode)
        @dsl_mode == :default ? Core::Goal : Core::GoalTemplate
      end

      def start_defrel
        @dsl_mode = :defrel
        @defrel_formals = Set.new
      end

      def end_defrel
        default_mode
      end

      def add_defrel(aDefRelation)
        @defrels = {} unless instance_variable_defined?(:@defrels)
        @defrels[aDefRelation.name] = aDefRelation
      end

      def method_missing(mth, *args)
        result = nil

        begin
          result = super(mth, *args)
        rescue NameError
          name = mth.id2name
          @defrels = {} unless instance_variable_defined?(:@defrels)
          if @defrels.include?(name)
            def_relation = @defrels[name]
            result = Core::Goal.new(def_relation, args.map { |el| convert(el) })
          else
            default_mode unless instance_variable_defined?(:@dsl_mode)
            if @dsl_mode == :defrel && @defrel_formals.include?(name)
              result = Core::FormalRef.new(name)
            else
              result = Core::LogVarRef.new(name)
            end
          end
        end

        result
      end
    end # module
  end # module
end # module
