# frozen_string_literal: true

require_relative 'environment'

module MiniKraken
  module Core
    class CompositeGoal
      # @return [Operator] The operator corresponding to this goal
      attr_reader :operator

      # @return [Array<Goal>] The child goals (sub-goals)
      attr_reader :children

      # @param anOperator [Operator] The operator corresponding to this goal
      # @param theChildren [Array<Goal>] The child goals (sub-goals)
      def initialize(anOperator, theChildren)
        @operator = anOperator
        @children = validated_children(theChildren)
      end

      # Attempt to achieve the goal for a given context (environment)
      # @param anEnv [Environment] The context in which the goal take place.
      # @return [Fiber<Outcome>] A Fiber object that will generate the results.
      def attain(anEnv)
        operator.solver_for(children, anEnv)
      end

      private

      def validated_children(theChildren)
        my_arity = operator.arity
        if args.size != my_arity
          err_msg = "Goal has #{theChildren.size} arguments, expected #{my_arity}"
          raise StandardError, err_msg
        end

        prefix = 'Invalid goal argument '
        theChildren.each do |subg|
          raise StandardError, prefix + subg.to_s unless subg.kind_of?(Goal)
        end

        theChildren.dup
      end
    end # class
  end # module
end # module
