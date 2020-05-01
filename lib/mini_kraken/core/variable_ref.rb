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
      def bound?(env)
        freshness = env.freshness_ref(self)
        freshness.degree == :bound
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
        val.nil? ? AnyValue.new(var_name, env, names_fused(env)) : val
      end

      # param another [VariableRef]
      # @param env [Environment]
      # @return [Boolean]
      def fused_with?(another, env)
        # I should point to 'another'...
        other_name = another.var_name
        to_another = values(env).find do |val|
          val.kind_of?(VariableRef) && val.var_name == other_name
        end
        return false unless to_another

        # 'another' should point to me
        to_me = another.values(env).find do |val|
          val.kind_of?(VariableRef) && val.var_name == var_name
        end
        !to_me.nil?
      end

      def names_fused(env)
        to_others = values(env).select do |val|
          val.kind_of?(VariableRef)
        end
        return [] if to_others.empty?

        # 'others' should point to me
        to_me = to_others.select do |other|
          other.values(env).find do |val|
            val.kind_of?(VariableRef) && val.var_name == var_name
          end
        end

        to_me.map { |other| other.var_name }
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
          raise StandardError, "Variable name may not be empty."
        end

        aName
      end


    end # class
  end # module
end # module
