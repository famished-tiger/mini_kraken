require_relative 'vocabulary'

module MiniKraken
  module Core
    class Environment
      include Vocabulary  # Use mix-in module

      # @return [Hash] Pairs of the kind {String => Variable}
      attr_reader :vars

      # @param aParent [Environment, NilClass] Parent environment to this one.
      def initialize(aParent = nil)
        init_vocabulary(aParent)
        @vars = {}
      end

      # @param aVariable [Variable]
      def add_var(aVariable)
        name = aVariable.name
        if vars.include?(name)
          err_msg = "Variable with name '#{name}' already exists."
          raise StandardError, err_msg
        end
        vars[name] = aVariable
      end

      # Handler for the event: an outcome has been produced.
      # Can be overridden in other to propagate associations from child
      # @param descendent [Outcome]
      def propagate(descendent)
        # Rollout associations from hierarchy
        walker = descendent.ancestor_walker
        begin
          env = walker.resume
          break if env.nil?
          env.do_propagate(descendent) if env.kind_of?(Environment) 
        end until env.equal?(self)
      end

      # Move associations from descendent outcome object
      def do_propagate(descendent)
        return unless descendent.successful? 

        vars.each_key do |var_name|
          assocs = descendent[var_name]
          assocs.each do |assoc|
            own = self[var_name]
            add_assoc(assoc) unless assoc.equal?(own)
          end
          descendent.associations.delete(var_name) unless assocs.empty?
        end
      end

      def merge_vars(descendent)
        descendent.vars.each_value { |vr| add_var(vr) }
      end
    end # class
  end # module
end # module