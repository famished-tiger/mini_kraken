# frozen_string_literal: true

require 'singleton'
require_relative 'duck_fiber'
require_relative 'goal'
require_relative 'goal_relation'
require_relative 'outcome'

unless MiniKraken::Core.constants(false).include? :Conj2
  module MiniKraken
    module Core
      # The conjunction is a relation that accepts only goal(s) as its two
      # arguments. It succeeds if and only both its goal arguments succeeds.
      class Conj2 < GoalRelation
        include Singleton

        def initialize
          super('conj2', nil)
        end

        # @param actuals [Array<Term>] A two-elements array
        # @param anEnv [Vocabulary] A vocabulary object
        # @return [Fiber<Outcome>] A Fiber that yields Outcomes objects
        def solver_for(actuals, anEnv)
          g1, g2 = *validated_args(actuals)
          Fiber.new { conjunction(g1, g2, anEnv) }
        end

        # Yields [Outcome, NilClass] result of the conjunction
        # @param g1 [Goal] First goal argument
        # @param g2 [Goal] Second goal argument
        # @param voc [Vocabulary] A vocabulary object
        def conjunction(g1, g2, voc)
          # require 'debug'
          outcome1 = nil
          outcome2 = nil
          if g1.relation.kind_of?(Fail) || g2.relation.kind_of?(Fail)
            Fiber.yield Outcome.new(:"#u", voc)
          else
            f1 = g1.attain(voc)
            loop do
              outcome1 = f1.resume
              break unless outcome1

              outcome1.parent = voc unless outcome1.parent
              if outcome1.successful?
                f2 = g2.attain(outcome1)
                loop do
                  outcome2 = f2.resume
                  break unless outcome2

                  outcome2.parent = voc unless outcome2.parent
                  if outcome2.successful?
                    res = Outcome.new(:"#s", voc)
                    res.merge(outcome1)
                    res.merge(outcome2)
                    Fiber.yield res
                  else
                    Fiber.yield outcome2
                  end
                  outcome2.clear
                end
              else
                Fiber.yield outcome1
              end
              voc.clear if outcome1&.successful? && outcome2&.successful?
            end
          end

          Fiber.yield nil
        end
      end # class

      Conj2.instance.freeze
    end # module
  end # module
end # unless
