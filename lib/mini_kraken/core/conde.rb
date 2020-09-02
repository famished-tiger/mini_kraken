# frozen_string_literal: true

require 'singleton'
require_relative 'conj2'
require_relative 'duck_fiber'
require_relative 'fail'
require_relative 'goal'
require_relative 'goal_relation'
require_relative 'outcome'

unless MiniKraken::Core.constants(false).include? :Conde
  module MiniKraken
    module Core
      # A polyadic relation (i.e. it can takes an arbitrary number of argumentt)
      # that behaves as the disjunction of its arguments.
      # It succeeds if at least one of its goal arguments succeeds.
      class Conde < GoalRelation
        include Singleton

        def initialize
          super('conde', nil)
        end

        # A relation is polyadic when it accepts an arbitrary number of arguments.
        # @return [TrueClass]
        def polyadic?
          true
        end

        # @param actuals [Array<Term>] A two-elements array
        # @param anEnv [Vocabulary] A vocabulary object
        # @return [Fiber<Outcome>] A Fiber that yields Outcomes objects
        def solver_for(actuals, anEnv)
          args = *validated_args(actuals)
          Fiber.new { cond(args, anEnv) }
        end

        # Yields [Outcome, NilClass] result of the disjunction
        # @param goals [Array<Goal>] Array of goals
        # @param voc [Vocabulary] A vocabulary object
        def cond(goals, voc)
          # require 'debug'
          success = false

          goals.each do |g|
            fiber = nil

            case g
              when Core::Goal
                fiber = g.attain(voc)
              when Core::Environment
                fiber = g.attain(voc)
              when Array
                conjunct = conjunction(g)
                fiber = conjunct.attain(voc)
              when Core::ConsCell
                goal_array = to_goal_array(g)
                conjunct = conjunction(goal_array)
                fiber = conjunct.attain(voc)
            end
            loop do
              outcome = fiber.resume
              break unless outcome

              outcome.parent = voc unless outcome.parent
              if outcome.success?
                success = true
                Fiber.yield outcome
                outcome.clear
              end
            end
          end

          Fiber.yield Outcome.new(:"#u", voc) unless success
          Fiber.yield nil
        end

        private

        def validated_args(actuals)
          result = []

          actuals.each do |arg|
            case arg
              when Core::Goal
                result << arg

              when Core::Environment
                result << arg

              when Array
                result << validated_args(arg)

              else
                prefix = "#{name} expects goal as argument, found a "
                raise StandardError, prefix + "'#{arg.class}'"
            end
          end

          result
        end

        def conjunction(goal_array)
          result = nil

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

          result
        end

        def to_goal_array(aCons)
          array = []
          curr_node = aCons
          loop do
            array << curr_node.car if curr_node.car.kind_of?(Core::Goal)
            break unless curr_node.cdr
            break unless curr_node.car.kind_of?(Core::Goal)

            curr_node = curr_node.cdr
          end

          array
        end
      end # class

      Conde.instance.freeze
    end # module
  end # module
end # unless
