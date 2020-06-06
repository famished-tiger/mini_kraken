# frozen_string_literal: true

require_relative '../core/any_value'
require_relative '../core/cons_cell'
require_relative 'fresh_env'

module MiniKraken
  module Glue
    class RunStarExpression
      attr_reader :env

      # @param var_names [String, Array<String>] One variable name or an array of names
      # @param goal [Core::Goal, Array<Core::Goal>] A single goal or an array of goals to conjunct
      def initialize(var_names, goal)
        vnames = var_names.kind_of?(String) ? [var_names] : var_names
        @env = FreshEnv.new(vnames, goal)
      end

      def run
        result = []
        solver = env.goal.attain(env)
        # require 'debug'
        loop do
          env.clear
          env.clear_rankings
          outcome = solver.resume
          break if outcome.nil?

          env.propagate(outcome) if result.empty? && outcome.successful?
          result << build_solution(outcome)
        end

        format_solutions(result)
      end

      private

      # @return [Array] A vector of assignment for each variable
      def build_solution(outcome)
        sol = env.vars.values.map do |var|
          outcome.successful? ? var.quote(outcome) : nil
        end

        sol
      end

      # Transform the solutions into sequence of conscells.
      # @param solutions [Array<Array>] An array of solution.
      # A solution is in itself an array of bindings (one per variable)
      def format_solutions(solutions)
        solutions_as_list = solutions.map { |sol| arr2list(sol, true) }
        arr2list(solutions_as_list, false)
      end

      # Utility method. Transform an array into a ConsCell-based list.
      # @param anArray [Array]
      # @param simplify [Boolean]
      def arr2list(anArray, simplify)
        return anArray[0] if anArray.size == 1 && simplify

        new_tail = nil
        anArray.reverse_each do |elem|
          new_tail = Core::ConsCell.new(elem, new_tail)
        end

        new_tail
      end
    end # class
  end # module
end # module
