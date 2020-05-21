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
        solver = env.goal.attain(env)
        # require 'debug'
        loop do
          outcome = solver.resume
          break if outcome.nil?

          env.clear
          if result # ... more than one result...
          elsif outcome.successful?
            env.propagate(outcome)
            result = Core::ConsCell.new(var.quote(outcome))
          else
            result = Core::NullList
            env.associations.freeze
          end
        end

        result
      end
    end # class
  end # module
end # module
