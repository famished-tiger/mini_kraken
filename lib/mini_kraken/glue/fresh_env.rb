# frozen_string_literal: true

require_relative '../core/environment'
require_relative '../core/conj2'
require_relative '../core/goal_template'
require_relative '../core/variable'

module MiniKraken
  module Glue
    # A combination of an Environment (= a scope for one or more variables)
    # and a goal. It quacks like a Goal object: when receiving the attain message,
    # it attempts to achieve its given goal.
    # (fresh (x) (== 'pea q))
    # Introduces the new variable 'x'
    # Takes a list of names and a goal-like object
    # Must respond to message attain(aPublisher, vars) and must return an Outcome
    class FreshEnv < Core::Environment
      # @return [Goal]
      attr_reader :goal

      # @return [TrueClass, FalseClass] Do associations persist after goal exec?
      attr_reader :persistent

      # @param theNames [Array<String>] The variable names
      # @param aGoal [Goal, Array<Goal>] The goal to achieve or the conjunction of them.
      def initialize(theNames, aGoal, persistence = true)
        super()
        @goal = valid_goal(aGoal)
        theNames.each do |nm|
          var = Core::Variable.new(nm)
          add_var(var)
        end
        @persistent = persistence
      end

      # Attempt to achieve the goal given this environment
      # @param aParent [Environment]
      # @return [Fiber<Outcome>] A Fiber object that will generate the results.
      def attain(aParent)
        # require 'debug'
        self.parent = aParent
        goal.attain(self)
      end

      # Remove associations of variables of this environment, if
      # persistence flag is set to false.
      def prune(anOutcome)
        return super(anOutcome) if persistent

        vars.each_value do |v|
          v_name = v.name
          if anOutcome.associations.include?(v_name)
            anOutcome.associations.delete(v_name)
          end
        end

        anOutcome
      end

      protected

      def introspect
        +", @vars=[#{vars.keys.join(', ')}]"
      end

      private

      def valid_goal(aGoal)
        result = nil

        case aGoal
          when Core::Goal
            result = aGoal
          when FreshEnv
            result = aGoal
          when Core::GoalTemplate
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
          else
            raise StandardError, "Cannot handle argumment type #{aGoal.class}"
        end

        result
      end
    end # class
  end # module
end # module
