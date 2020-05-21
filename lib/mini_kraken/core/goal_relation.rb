# frozen_string_literal: true

require_relative 'relation'

module MiniKraken
  module Core
    # A specialization of a relation that accepts only goal(s)
    # as its arguments.
    class GoalRelation < Relation
      def arity
        2
      end
    end # class
  end # module
end # module
