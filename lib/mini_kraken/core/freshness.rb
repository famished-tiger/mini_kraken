module MiniKraken
  module Core
    # Freshness: fresh, bound, ground
    # fresh: no association at all
    # bound: associated to something that is itself not ground.
    # ground: associated to something that is either an atomic, a composite with ground members,
    #   a variable reference to something that is itself ground.
    # RS fresh == fresh or bound
    # RS not fresh == ground
    # RS result == fresh => any or bound => expr(any)
    Freshness = Struct.new(:degree, :associated) do
      def initialize(aDegree, anAssociated)
        super(aDegree, valid_associated(anAssociated))
      end
      
      def fresh?
        self.degree == :fresh
      end

      def bound?
        self.degree == :bound
      end

      def ground?
        self.degree == :ground
      end

      # Does this instance represent something fresh according to
      # "Reasoned Schemer" book ?
      def rs_fresh?
        self.degree != ground
      end
      
      private
      
      def valid_associated(anAssociated)
        raise StandardError, 'Wrong argument' if anAssociated.kind_of?(self.class)
        anAssociated
      end
    end # struct
  end # module
end # module