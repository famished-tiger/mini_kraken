require_relative 'any_value'
require_relative 'vocabulary'

module MiniKraken
  module Core
    # Representation of a MiniKraken variable.
    # It is a named slot that can be associated with one value.
    class Variable
      # @return [String] Name of the variable
      attr_reader :name

      # @param aName [String] The name of the variable
      def initialize(aName)
        @name = valid_name(aName)
      end

      def fresh?(anEnvironment)
        anEnvironment.fresh?(self)
      end

      # @param env [Environment]
      # @return [Freshness]
      def freshness(env)
        freshness = env.freshness_ref(self)
      end

      def ground?(anEnvironment)
        !fresh?(anEnvironment)
      end

      def quote(anEnvironment)
        raise StandardError, "class #{anEnvironment}" unless anEnvironment.kind_of?(Vocabulary)

        val = anEnvironment.quote_ref(self)
        val.nil? ? AnyValue.new(name, anEnvironment) : val
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
