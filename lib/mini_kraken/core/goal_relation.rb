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

      protected

      def validated_args(actuals)
        actuals.each do |arg|
          unless arg.kind_of?(Goal)
            prefix = "#{name} expects goal as argument, found a "
            raise StandardError, prefix + "'#{arg.class}'"
          end
        end

        actuals
      end
    end # class
  end # module
end # module
