module MiniKraken
  module Core
    class Goal
      attr_reader :relation

      def initialize(aRelation, args)
        @relation = aRelation
      end
      
      def attain(aPublisher, vars)
        aPublisher.broadcast_entry(self, vars)
        outcome = relation.unify(self, vars)
        aPublisher.broadcast_exit(self, vars, outcome)
        outcome
      end
    end # class
  end # module
end # module