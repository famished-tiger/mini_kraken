# frozen_string_literal: true

require_relative 'base_arg'

module MiniKraken
  module Core
    # A meta-goal that is parametrized with generic formal arguments.
    # The individual goals are instantiated when the formal arguments
    # are bound to goal arguments
    class GoalTemplate < BaseArg
      # @return [Array<BaseArg>] Arguments of goal template.
      attr_reader :args

      # @return [Relation] Main relation for the goal template
      attr_reader :relation

      def initialize(aRelation, theArgs)
        super()
        @relation = validated_relation(aRelation)
        @args = validated_args(theArgs)
        freeze
      end

      # @param formals [Array<FormalArg>] Array of formal arguments
      # @param actuals [Array<GoalArg>] Array of actual arguments
      # @return [Goal] instantiate a goal object given the actuals and environment
      def instantiate(formals, actuals)
        formals2actuals = {}
        formals.each_with_index do |frml, i|
          formals2actuals[frml.name] = actuals[i]
        end

        do_instantiate(formals2actuals)
      end

      private

      def validated_relation(aRelation)
        aRelation
      end

      def validated_args(theArgs)
        theArgs
      end

      def do_instantiate(formals2actuals)
        goal_args = []
        args.each do |arg|
          if arg.kind_of?(FormalRef)
            goal_args << formals2actuals[arg.name]
          elsif arg.kind_of?(GoalTemplate)
            goal_args << arg.send(:do_instantiate, formals2actuals)
          else
            goal_args << arg
          end
        end

        Goal.new(relation, goal_args)
      end
    end # class
  end # module
end # module
