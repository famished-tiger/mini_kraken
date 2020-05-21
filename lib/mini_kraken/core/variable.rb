# frozen_string_literal: true

require_relative 'designation'
require_relative 'any_value'
require_relative 'vocabulary'

module MiniKraken
  module Core
    # Representation of a MiniKraken variable.
    # It is a named slot that can be associated with one value.
    class Variable
      include Designation # Mixin: Acquire name attribute

      # @return [String] Internal variable name used by MiniKraken
      attr_accessor :i_name

      # @param aName [String] The name of the variable
      def initialize(aName)
        init_designation(aName)
        @i_name = name.dup
      end

      def fused?
        name != i_name
      end

      def quote(anEnvironment)
        raise StandardError, "class #{anEnvironment}" unless anEnvironment.kind_of?(Vocabulary)

        val = anEnvironment.quote_ref(self)
        val.nil? ? AnyValue.new(name, anEnvironment) : val
      end
    end # class
  end # module
end # module
