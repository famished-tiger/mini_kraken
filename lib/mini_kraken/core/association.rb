module MiniKraken
  module Core
    # A record that a given vairable is associated with a value.
    class Association
      # @return [String] name of the variable beig association the value.
      attr_reader :var_name
      
      # @return [Term] the MiniKraken value associated with the variable
      attr_reader :value
      
      
      # @param aVariable [Variable, String] A variable or its name.
      # @param aValue [Term] value being associated to the variable.
      def initialize(aVariable, aValue)
        @var_name = aVariable.respond_to?(:name) ? aVariable.name : aVariable
        @value = aValue
      end
      
    end # class
  end # module
end # module
