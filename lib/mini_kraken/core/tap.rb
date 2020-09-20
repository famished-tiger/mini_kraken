# frozen_string_literal: true

require 'singleton'
require_relative 'duck_fiber'
require_relative 'goal'
require_relative 'goal_relation'
require_relative 'outcome'

module MiniKraken
  module Core
    class Tap < GoalRelation
      include Singleton

      def initialize
        super('tap', nil)
      end

      def arity
        1
      end

      # @param actuals [Array<Term>] A two-elements array
      # @param anEnv [Vocabulary] A vocabulary object
      # @return [Fiber<Outcome>] A Fiber that yields Outcomes objects
      def solver_for(actuals, anEnv)
        args = *validated_args(actuals)
        DuckFiber.new(:custom) do
          outcome = tap(args.first, anEnv)
          # outcome.prune!
        end
      end

      def tap(aGoal, anEnv)
        require 'debug'
        f1 = aGoal.attain(anEnv)
        outcome1 = f1.resume
        # key = outcome1.associations.keys.first
        # outcome1.associations['x'] = outcome1.associations[key]
        # outcome1.associations.delete(key)
        outcome1
      end
    end # class

    Tap.instance.freeze
  end # module
end # module
