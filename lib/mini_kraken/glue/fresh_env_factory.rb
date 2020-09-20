# frozen_string_literal: true

require_relative '../core/environment'
require_relative '../core/conj2'
require_relative '../core/goal_template'
require_relative '../core/log_var'
require_relative 'fresh_env'

module MiniKraken
  module Glue
    # A combination of an Environment (= a scope for one or more variables)
    # and a goal. It quacks like a Goal template object: when receiving the
    # instantiate message, it creates a FreshEnv.
    class FreshEnvFactory
      # @return [Array<String>] The names of variables to be.
      attr_reader :names

      # @return [GoalTemplate] The goal template
      attr_reader :goal_template

      # @param theNames [Array<String>] The names of variables to build.
      # @param aGoal [GoalTemplate, Array<Goal>] The goal template(s)
      def initialize(theNames, aGoalTemplate)
        @goal_template = valid_goal_template(aGoalTemplate)
        @names = valid_names(theNames)
      end

      # Factory method: Create a goal object.
      # @param formals [Array<FormalArg>] Array of formal arguments
      # @param actuals [Array<GoalArg>] Array of actual arguments
      # @return [Goal] instantiate a goal object given the actuals and environment
      def instantiate(formals, actuals)
        # require 'debug'
        goal = goal_template.instantiate(formals, actuals)
        FreshEnv.new(names, goal, false)
      end

      protected

      def introspect
        +", @names=[#{names.join(', ')}]"
      end

      private

      def valid_names(theNames)
        theNames
      end

      def valid_goal_template(aGoalTemplate)
        result = nil

        case aGoalTemplate
          when FreshEnvFactory
            result = aGoalTemplate
          when Core::GoalTemplate
            result = aGoalTemplate
          # when Array # an Array of Goal?..
            # goal_array = aGoalTemplate
            # loop do
              # conjunctions = []
              # goal_array.each_slice(2) do |uno_duo|
                # if uno_duo.size == 2
                  # conjunctions << Core::GoalTemplate.new(Core::Conj2.instance, uno_duo)
                # else
                  # conjunctions << uno_duo[0]
                # end
              # end
              # if conjunctions.size == 1
                # result = conjunctions[0]
                # break
              # end
              # goal_array = conjunctions
            # end
          else
            raise StandardError, "Cannot handle argumment type #{aGoalTemplate.class}"
        end

        result
      end
    end # class
  end # module
end # module
