# frozen_string_literal: true

require_relative '../core/any_value'
require_relative '../core/conj2'
require_relative '../core/cons_cell'
require_relative '../core/disj2'
require_relative '../core/equals'
require_relative '../core/fail'
require_relative '../core/k_symbol'
require_relative '../core/succeed'
require_relative '../core/variable_ref'
require_relative 'fresh_env'
require_relative 'run_star_expression'


module MiniKraken
  module Glue
    module DSL
      # @return [Core::ConsCell] A list of solutions
      def run_star(var_names, goal)
        program = RunStarExpression.new(var_names, goal)
        program.run
      end

      def conj2(arg1, arg2)
        Core::Goal.new(Core::Conj2.instance, [convert(arg1), convert(arg2)])
      end

      def cons(car_item, cdr_item = nil)
        Core::ConsCell.new(convert(car_item), convert(cdr_item))
      end

      def disj2(arg1, arg2)
        Core::Goal.new(Core::Disj2.instance, [convert(arg1), convert(arg2)])
      end

      def _fail
        Core::Goal.new(Core::Fail.instance, [])
      end

      def equals(arg1, arg2)
        Core::Goal.new(Core::Equals.instance, [convert(arg1), convert(arg2)])
      end

      def fresh(var_names, goal)
        vars = nil

        if var_names.kind_of?(String) || var_names.kind_of?(Core::VariableRef)
          vars = [var_names]
        elsif

          vars = var_names
        end
        FreshEnv.new(vars, goal)
      end

      def null
        Core::ConsCell.new(nil, nil)
      end

      def succeed
        Core::Goal.new(Core::Succeed.instance, [])
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
            else
              converted = Core::KSymbol.new(anArgument)
            end
          when Core::Goal
            converted = anArgument
          when Core::VariableRef
            converted = anArgument
          when Core::ConsCell
            converted = anArgument
        end

        converted
      end

      def method_missing(mth, *args)
        result = nil

        begin
          result = super(mth, *args)
        rescue NameError
          result = Core::VariableRef.new(mth.id2name)
        end

        result
      end
    end # module
  end # module
end # module
