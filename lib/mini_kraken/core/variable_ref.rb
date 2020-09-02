# frozen_string_literal: true

require_relative 'term'
require_relative 'designation'
require_relative 'any_value'

module MiniKraken
  module Core
    # A variable reference represents the occurrence of a variable (name) in a
    # MiniKraken term.
    class VariableRef < Term
      include Designation # Mixin: Acquire name attribute
      alias var_name name

      # @param aName [String] The name of the variable
      def initialize(aName)
        super()
        init_designation(aName)
        name.freeze
      end

      def to_s
        name
      end

      # @param aValue [Term]
      # @param env [Environment]
      def associate(aValue, env)
        env.add_assoc(var_name, aValue)
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
      def quote(env)
        val = env.quote_ref(self)
        val.nil? ? AnyValue.new(var_name, env, names_fused(env)) : val
      end

      # param another [VariableRef]
      # @param env [Environment]
      # @return [Boolean]
      def fused_with?(another, env)
        my_var = env.name2var(var_name)
        return false unless my_var.fused?

        other_var = env.name2var(another.var_name)
        return my_var.i_name == other_var.i_name
      end

      def names_fused(env)
        env.names_fused(var_name)
      end

      # param another [VariableRef]
      # @param env [Environment]
      # @return [Boolean]
      def different_from?(another, env)
        !fused_with?(another, env)
      end

      private

      def valid_name(aName)
        if aName.empty?
          raise StandardError, 'Variable name may not be empty.'
        end

        aName
      end
    end # class
  end # module
end # module
