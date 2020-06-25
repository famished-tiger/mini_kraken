# frozen_string_literal: true

require_relative 'relation'

module MiniKraken
  module Core
    # A relation that is parametrized with generic formal arguments
    # and a goal template expression.
    class DefRelation < Relation
      # @return [Array<FormalArg>] formal arguments of this DefRelation
      attr_reader :formals

      # @return [GoalTemplate] goal template
      attr_reader :goal_template

      # @param aName [String] name of def relation
      # @param aGoalTemplate [GoalTemplate]
      def initialize(aName, aGoalTemplate, theFormals, alternateName = nil)
        super(aName, alternateName)
        @formals = validated_formals(theFormals)
        @goal_template = validated_goal_template(aGoalTemplate)
      end

      # Number of arguments for the relation.
      # @return [Integer]
      def arity
        formals.size
      end

      # @param actuals [Array<Term>] A two-elements array
      # @param anEnv [Vocabulary] A vocabulary object
      # @return [Fiber<Outcome>] A Fiber(-like) instance that yields Outcomes
      def solver_for(actuals, anEnv)
        goal = goal_template.instantiate(formals, actuals)
        goal.attain(anEnv)
      end

      private

      def validated_formals(theFormals)
        theFormals
      end

      def validated_goal_template(aGoalTemplate)
        aGoalTemplate
      end
    end # class
  end # module
end # module
