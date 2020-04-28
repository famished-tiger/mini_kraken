require_relative 'association_walker'

module MiniKraken
  module Core
    module Vocabulary
      # @return [Environment] Parent environment to this one.
      attr_accessor :parent

      # @return [Hash] Pairs of the kind {String => Array[Association]}
      attr_reader :associations

      # @param aParent [Environment, NilClass] Parent environment to this one.
      def init_vocabulary(aParent = nil)
        @parent = validated_parent(aParent)
        @associations = {}
      end

      # Return a Fiber object that can iterate over this vocabulary and
      # all its direct and indirect parent(s).
      # @return [Fiber<Vocabulary, NilClass>]
      def ancestor_walker
        Fiber.new do
          relative = self
          while relative do
            Fiber.yield relative
            relative = relative.parent
          end

          Fiber.yield nil # nil marks end of iteration...
        end
      end

      # Record an association between a variable with given name and a term.
      # @param anAssociation [Association]
      def add_assoc(anAssociation)
        name = anAssociation.var_name
        unless include?(name)
          err_msg = "Unknown variable '#{name}'."
          raise StandardError, err_msg
        end
        found_assocs = associations[name]
        if found_assocs
          found_assocs << anAssociation
        else
          associations[name] = [anAssociation]
        end
      end

      # Handler for the event: an outcome has been produced.
      # Can be overridden in other to propagate associations from child
      # @param _descendent [Outcome]
      def propagate(_descendent)
        #Do nothing...
      end

      # Remove all the associations.
      def clear
        associations.clear
      end

      # Merge the associations from another vocabulary-like object.
      # @param another [Vocabulary]
      def merge(another)
        another.associations.each_pair do |_name, assocs|
          assocs.each { |a| add_assoc(a) }
        end
      end

      # @param var [Variable, VariableRef] the variable to check.
      # @return [Boolean]
      def fresh?(var)
        ground_term = ground_value(var)
        ground_term.nil? ? true : false
      end

      # @param var [Variable, VariableRef] variable for which the value to retrieve
      # @return [Term, NilClase]
      def ground_value(var)
        name = var.respond_to?(:var_name) ? var.var_name : var.name

        walker = AssociationWalker.new
        walker.find_ground(name, self)
      end

      # @param var [CompositeTerm] the composite term to check.
      # @return [Boolean]
      def fresh_value?(val)
        walker = AssociationWalker.new
        ground_term = walker.walk_value(val, self)
        ground_term.nil? ? true : false
      end
      
      # A composite term is fresh when all its members are nil or all non-nil members
      # are all fresh
      # A composite term is bound when it is not fresh and not ground      
      # A composite term is a ground term when all its non-nil members are ground.
      # @param aComposite [CompositeTerm]
      # @return [Freshness]      
      def freshness_composite(aComposite)
        walker = AssociationWalker.new
        walker.freshness_composite(aComposite)
      end

      # Determine whether the reference points to a fresh, bound or ground term.
      # @param aVariableRef [VariableRef]
      # @return [Freshness]
     def freshness_ref(aVariableRef)
        walker = AssociationWalker.new
        walker.determine_freshness(aVariableRef, self)
      end

      # @param aVariableRef [VariableRef]
      # @return [Term, NilClass]      
      def quote_ref(aVariableRef)
        walker = AssociationWalker.new
        walker.quote_term(aVariableRef, self)      
      end

      # @param aName [String]
      # @return [Array<Association>]
      def [](aName)
        assoc_arr = associations[aName]
        assoc_arr = [] if assoc_arr.nil?

        assoc_arr.concat(parent[aName]) if parent
        assoc_arr
      end

      # Check that a variable with given name is defined in this vocabulary
      # of one of its ancestor.
      # @return [Boolean]
      def include?(aVarName)
        var_found = false
        walker = ancestor_walker
        loop do
          voc = walker.resume
          if voc
            next unless voc.respond_to?(:vars) && voc.vars.include?(aVarName)
            var_found = true
          end

          break
        end

        var_found
      end

      protected

      def validated_parent(aParent)
        if aParent
          unless aParent.kind_of?(Vocabulary)
            raise StandardError, "Invalid parent type #{aParent.class}"
          end
        end

        aParent
      end
    end # class
  end # module
end # module