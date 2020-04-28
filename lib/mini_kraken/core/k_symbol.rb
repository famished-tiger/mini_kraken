require_relative 'atomic_term'

module MiniKraken
  module Core
    # A specialized atomic term that represents a symbolic value.
    # in MiniKraken   
    class KSymbol < AtomicTerm
    
      # @param aValue [Symbol] Ruby representation of symbol value
      def initialize(aValue)
        super(aValue)
      end
    end # class
  end # module
end # module