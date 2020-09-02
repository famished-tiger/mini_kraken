# frozen_string_literal: true

require_relative 'base_arg'
require_relative 'cons_cell_visitor'

module MiniKraken
  module Core
    # A meta-goal that is parametrized with generic formal arguments.
    # The individual goals are instantiated when the formal arguments
    # are bound to goal arguments.
    class GoalTemplate < BaseArg
      # @return [Array<BaseArg>] Arguments of goal template.
      attr_reader :args

      # @return [Relation] Main relation for the goal template
      attr_reader :relation

      # @param aRelation [Core::Rzlation] the relation
      # @param theArgs [Array<Core::BaseArg>] Arguments of goal template.
      def initialize(aRelation, theArgs)
        super()
        @relation = validated_relation(aRelation)
        @args = validated_args(theArgs)
        args.freeze
      end

      # Factory method: Create a goal object.
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
          elsif arg.kind_of?(ConsCell)
            # if list contains a formal_ref it must be replaced by the actual
            goal_args << transform(arg, formals2actuals)
          else
            goal_args << arg
          end
        end

        Goal.new(relation, goal_args)
      end

      private

      def transform(aConsCell, formals2actuals)
        return aConsCell if aConsCell.null?

        member = { car: :@car, cdr: :@cdr }
        visitor = ConsCellVisitor.df_visitor(aConsCell)
        side, cell = visitor.resume
        result = ConsCell.new(nil, nil)
        node = result

        loop do
          side, cell = visitor.resume
          break if side == :stop

          converted = nil
          case cell
            when FormalRef
              converted = formals2actuals[cell.name]
            when ConsCell
              converted = ConsCell.new(nil, nil)
            when GoalTemplate
              converted = cell.send(:do_instantiate, formals2actuals)
            else
              converted = cell
          end
          node.instance_variable_set(member[side], converted)
          node = converted if converted.kind_of?(ConsCell)
        end

        result
      end
    end # class
  end # module
end # module
