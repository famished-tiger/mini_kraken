# frozen_string_literal: true

require 'singleton'
require_relative 'duck_fiber'
require_relative 'fail'
require_relative 'goal'
require_relative 'goal_relation'
require_relative 'outcome'

unless MiniKraken::Core.constants(false).include? :Disj2
  module MiniKraken
    module Core
      # The disjunction is a relation that accepts only goal(s) as its two
      # arguments. It succeeds if at least one of its goal arguments succeeds.
      class Disj2 < GoalRelation
        include Singleton

        def initialize
          super('disj2', nil)
        end

        # @param actuals [Array<Term>] A two-elements array
        # @param anEnv [Vocabulary] A vocabulary object
        # @return [Fiber<Outcome>] A Fiber that yields Outcomes objects
        def solver_for(actuals, anEnv)
          g1, g2 = *validated_args(actuals)
          Fiber.new { disjunction(g1, g2, anEnv) }
        end

        # Yields [Outcome, NilClass] result of the disjunction
        # @param g1 [Goal] First goal argument
        # @param g2 [Goal] Second goal argument
        # @param voc [Vocabulary] A vocabulary object
        def disjunction(g1, g2, voc)
          # require 'debug'
          outcome1 = nil
          outcome2 = nil
          if g1.relation.kind_of?(Fail) && g2.relation.kind_of?(Fail)
            Fiber.yield Outcome.new(:"#u", voc)
          else
            f1 = g1.attain(voc)
            loop do
              outcome1 = f1.resume
              break unless outcome1

              outcome1.parent = voc unless outcome1.parent
              if outcome1.successful?
                Fiber.yield outcome1
                outcome1.clear
              end
            end
            f2 = g2.attain(voc)
            loop do
              outcome2 = f2.resume
              break unless outcome2

              outcome2.parent = voc unless outcome2.parent
              if outcome2.successful?
                Fiber.yield outcome2
                outcome2.clear
              end
            end
          end

          Fiber.yield nil
        end
      end # class

      Disj2.instance.freeze
    end # module
  end # module
end # unless
