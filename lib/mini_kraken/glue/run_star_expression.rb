# frozen_string_literal: true

require_relative '../core/any_value'
require_relative '../core/cons_cell'
require_relative 'fresh_env'

module MiniKraken
  module Glue
    class RunStarExpression
      attr_reader :env

      # @param var_name [String]
      # @param goal [Core::Goal]
      def initialize(var_name, goal)
        @env = FreshEnv.new([var_name], goal)
      end

      def var
        env.vars.values.first
      end

      def run
        result = nil
        next_result = nil
        solver = env.goal.attain(env)
        # require 'debug'
        loop do
          env.clear
          env.clear_rankings
          outcome = solver.resume
          break if outcome.nil?

          if result # ... more than one result...
            if outcome.successful?
              next_result.append(Core::ConsCell.new(var.quote(outcome)))
            else
              next_result.append(Core::NullList)
            end
            next_result = next_result.cdr
          elsif outcome.successful?
            env.propagate(outcome)
            result = Core::ConsCell.new(var.quote(outcome))
            next_result = result
          else
            result = Core::NullList
            next_result = result
          end
        end

        result
      end
    end # class
  end # module
end # module
