# frozen_string_literal: true

require_relative 'environment'

module MiniKraken
  require_relative 'goal_arg'

  module Core
    class Goal < GoalArg
      # @return [Relation] The relation corresponding to this goal
      attr_reader :relation

      # @return [Array<Term>] The actual aguments of the goal
      attr_reader :actuals

      # @param aRelation [Relation] The relation corresponding to this goal
      # @param args [Array<Term>] The actual aguments of the goal
      def initialize(aRelation, args)
        super()
        @relation = aRelation
        @actuals = validated_actuals(args)
      end

      # Attempt to achieve the goal for a given context (environment)
      # @param anEnv [Environment] The context in which the goal take place.
      # @return [Fiber<Outcome>] A Fiber object that will generate the results.
      def attain(anEnv)
        relation.solver_for(actuals, anEnv)
      end

      private

      def validated_actuals(args)
        if !relation.polyadic? && (args.size != relation.arity)
          err_msg = "Goal has #{args.size} arguments, expected #{relation.arity}"
          raise StandardError, err_msg
        end

        prefix = 'Invalid goal argument'
        args.each do |actual|
          if actual.kind_of?(GoalArg) || actual.kind_of?(Environment)
            next
          elsif actual.kind_of?(Array)
            validated_actuals(actual)
          else
            actual_display = actual.nil? ? 'nil' : actual.to_s
            raise StandardError, "#{prefix} '#{actual_display}'"
          end
        end

        args.dup
      end
    end # class
  end # module
end # module
