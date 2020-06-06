# frozen_string_literal: true

require_relative '../core/environment'
require_relative '../core/conj2'
require_relative '../core/variable'

module MiniKraken
  module Glue
    # A combination of an Environment (= a scope for one or more variables)
    # and a goal. It quacks like a Goal object: when receiving the attain message,
    # it attempt to achieve its given goal.
    # (fresh (x) (== 'pea q))
    # Introduces the new variable 'x'
    # Takes a list of names and a goal-like object
    # Must respond to message attain(aPublisher, vars) and must return an Outcome
    class FreshEnv < Core::Environment
      # @return [Goal]
      attr_reader :goal

      # @param theNames [Array<String>] The variable names
      # @param aGoal [Goal, Array<Goal>] The goal to achieve or the conjunction of them.
      def initialize(theNames, aGoal)
        super()
        @goal = valid_goal(aGoal)
        theNames.each { |nm| add_var(Core::Variable.new(nm)) }
      end

      # Attempt to achieve the goal given this environment
      # @param aParent [Environment]
      # @return [Fiber<Outcome>] A Fiber object that will generate the results.
      def attain(aParent)
        self.parent = aParent
        goal.attain(self)
      end

      private

      def valid_goal(aGoal)
        result = nil

        case aGoal
          when Core::Goal
            result = aGoal
          when FreshEnv
            result = aGoal
          when Array # an Array of Goal?..
            goal_array = aGoal
            loop do
              conjunctions = []
              goal_array.each_slice(2) do |uno_duo|
                if uno_duo.size == 2
                  conjunctions << Core::Goal.new(Core::Conj2.instance, uno_duo)
                else
                  conjunctions << uno_duo[0]
                end
              end
              if conjunctions.size == 1
                result = conjunctions[0]
                break
              end
              goal_array = conjunctions
            end
        end

        result
      end
    end # class
  end # module
end # module
