# frozen_string_literal: true

require 'set'
require_relative 'vocabulary'

module MiniKraken
  module Core
    class Environment
      include Vocabulary # Use mix-in module

      # Mapping from user-defined name to Variable instance
      # @return [Hash] Pairs of the kind {String => Variable}
      attr_reader :vars

      # Mapping from internal name to user-defined name(s)
      # @return [Hash] Pairs of the kind {String => Set<String>}
      attr_reader :ivars

      # @param aParent [Environment, NilClass] Parent environment to this one.
      def initialize(aParent = nil)
        init_vocabulary(aParent)
        @vars = {}
        @ivars = {}
      end

      # @param aVariable [Variable]
      def add_var(aVariable)
        name = aVariable.name
        if vars.include?(name)
          err_msg = "Variable with name '#{name}' already exists."
          raise StandardError, err_msg
        end
        vars[name] = aVariable
        i_name = aVariable.i_name
        if ivars.include?(i_name)
          set = ivars[i_name]
          set.add(name)
        else
          ivars[i_name] = Set.new([i_name])
        end
      end

      # Handler for the event: an outcome has been produced.
      # Can be overridden in other to propagate associations from child
      # @param descendent [Outcome]
      def propagate(descendent)
        # Rollout associations from hierarchy
        walker = descendent.ancestor_walker
        begin
          env = walker.next
          break if env.nil?

          env.do_propagate(descendent) if env.kind_of?(Environment)
        end until env.equal?(self)
      end

      # Roll up associations from descendent outcome object
      # @param descendent [Outcome]
      def do_propagate(descendent)
        return unless descendent.successful?

        vars.each_key do |var_name|
          # assocs = descendent[var_name]
          move_assocs(var_name, descendent)
        end
      end

      def merge_vars(descendent)
        descendent.vars.each_value { |vr| add_var(vr) }
      end
    end # class
  end # module
end # module
