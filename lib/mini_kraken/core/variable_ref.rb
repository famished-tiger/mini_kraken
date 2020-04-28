require_relative 'term'
require_relative 'any_value'
require_relative 'association'

module MiniKraken
  module Core
    # A variable reference represents the occurrence of a variable (name) in a
    # MiniKraken term.
    class VariableRef < Term
      # @return [String] Name of the variable
      attr_reader :var_name

      # @param aName [String] The name of the variable
      def initialize(aName)
        @var_name = valid_name(aName)
      end

      # @param env [Environment]
      # @return [Boolean]
      def fresh?(env)
        env.fresh?(self)
      end

      # @param env [Environment]
      # @return [Boolean]
      def ground?(env)
        !fresh?(env)
      end

      # @param aValue [Term]
      # @param env [Environment]
      def associate(aValue, env)
        assoc = Association.new(var_name, aValue)
        env.add_assoc(assoc)
      end

      # @param env [Environment]
      # @return [Array<Term>]
      def values(env)
        env[var_name].map(&:value)
      end

      # @param env [Environment]
      # @return [Term, NilClass]
      def value(env)
        freshness = env.freshness_ref(self)
        freshness.associated
      end
      
      # @param env [Environment]
      # @return [Freshness]
      def freshness(env)
        freshness = env.freshness_ref(self)
      end      
      

      # @param env [Environment]
      def quote(env)
        val = env.quote_ref(self)
        val.nil? ? AnyValue.new(0) : val
      end

      private

      def valid_name(aName)
        if aName.empty?
          raise StandardError, "Variable name may not be empty."
        end

        aName
      end


    end # class
  end # module
end # module
