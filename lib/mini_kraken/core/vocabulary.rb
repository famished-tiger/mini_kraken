# frozen_string_literal: true

require 'set'
require_relative 'association'
require_relative 'association_walker'

module MiniKraken
  module Core
    module Vocabulary
      # @return [Environment] Parent environment to this one.
      attr_accessor :parent

      # @return [Hash] Pairs of the kind {String => Array[Association]}
      attr_reader :associations

      # @return [Hash] Pairs of the kind {String => Integer}
      attr_reader :rankings

      # @param aParent [Environment, NilClass] Parent environment to this one.
      def init_vocabulary(aParent = nil)
        @parent = validated_parent(aParent)
        @associations = {}
        @rankings = {} unless aParent
      end

      # Return a Enumerator object that can iterate over this vocabulary and
      # all its direct and indirect parent(s).
      # @return [Enumerator<Vocabulary, NilClass>]
      def ancestor_walker
        unless @ancestors # Not yet in cache?...
          @ancestors = []
          relative = self
          while relative
            @ancestors << relative
            relative = relative.parent
          end
          @ancestors << nil # nil marks end of iteration...
        end

        @ancestors.to_enum
      end

      def clear_rankings
        walker = ancestor_walker
        orphan = nil
        loop do
          orphan_temp = walker.next
          break unless orphan_temp

          orphan = orphan_temp
        end

        orphan.rankings&.clear
      end

      # @param aName [String]
      # @param alternate_names [Array<String>]
      def get_rank(aName, alternate_names = [])
        walker = ancestor_walker
        orphan = nil
        loop do
          orphan_temp = walker.next
          break unless orphan_temp

          orphan = orphan_temp
        end

        raise StandardError unless orphan

        rank = nil
        if orphan.rankings.include?(aName)
          rank = orphan.rankings[aName]
        else
          other = alternate_names.find do |a_name|
            rank = orphan.rankings.include?(a_name)
          end
          if other
            rank = get_rank(other)
          else
            rank = orphan.rankings.keys.size
            orphan.rankings[aName] = rank
          end
        end

        rank
      end

      # Record an association between a variable with given user-defined name
      # and a term.
      # @param aName [String, Variable] A user-defined variable name
      # @param aTerm [Term] A term to associate with the variable
      def add_assoc(aName, aTerm)
        name = aName.respond_to?(:name) ? aName.name : aName

        var = name2var(name)
        unless var
          err_msg = "Unknown variable '#{name}'."
          raise StandardError, err_msg
        end
        siblings = detect_fuse(var, aTerm)
        if siblings.empty?
          anAssociation = Association.new(var.i_name, aTerm)
          do_add_assocs([anAssociation]).first
        else
          fuse_vars(siblings << var)
        end
      end

      # Handler for the event: an outcome has been produced.
      # Can be overridden in other to propagate associations from child
      # @param _descendent [Outcome]
      def propagate(_descendent)
        # Do nothing...
      end

      # Remove all the associations of this vocabulary
      def clear
        associations.clear
      end

      # @param aVarName [String] A user-defined variable name
      # @param other [Vocabulary]
      def move_assocs(aVarName, other)
        i_name = to_internal(aVarName)
        assocs = other.associations[i_name]
        if assocs
          do_add_assocs(assocs)
          other.associations.delete(i_name)
        end
      end

      # Merge the associations from another vocabulary-like object.
      # @param another [Vocabulary]
      def merge(another)
        another.associations.each_value { |assocs| do_add_assocs(assocs) }
      end

      # Check that the provided variable must be fused with the argument.
      # @return [Array<Variable>]
      def detect_fuse(aVariable, aTerm)
        return [] unless aTerm.kind_of?(VariableRef)

        assocs = self[aTerm.var_name]
        # Simplified implementation: cope with binary cycles only...
        # TODO: Extend to n-ary (n > 2) cycles
        assoc_refs = assocs.select { |a| a.value.kind_of?(VariableRef) }
        return [] if assoc_refs.empty? # No relevant association...

        visitees = Set.new
        to_fuse = []
        to_visit = assoc_refs
        loop do
          assc = to_visit.shift
          next if visitees.include?(assc)

          visitees.add(assc)
          ref = assc.value
          if ref.var_name == aVariable.name
            to_fuse << assc.i_name unless assc.i_name == aVariable.i_name
          end
          other_assocs = self[ref.var_name]
          other_assoc_refs = other_assocs.select { |a| a.value.kind_of?(VariableRef) }
          other_assoc_refs.each do |a|
            to_visit << a unless visitess.include?(a)
          end


          break if to_visit.empty?
        end

        to_fuse.map { |i_name| i_name2var(i_name) }
      end

      # Fuse the given variables:
      # Collect all their associations
      # Put them under a new internal name
      # Remove all entries from old internal names
      # For all fused variables, change internal names
      # @param theVars [Array<Variable>]
      def fuse_vars(theVars)
        new_i_name = Object.new.object_id.to_s
        fused_vars = theVars.dup
        fused_vars.each do |a_var|
          old_i_name = a_var.i_name
          old_names = fused_vars.map(&:name)
          walker = ancestor_walker

          loop do
            voc = walker.next
            break unless voc

            if voc.associations.include?(old_i_name)
              assocs = voc.associations[old_i_name]
              keep_assocs = assocs.reject do |assc|
                assc.value.kind_of?(VariableRef) && old_names.include?(assc.value.var_name)
              end
              unless keep_assocs.empty?
                keep_assocs.each { |assc| assc.i_name = new_i_name }
                if voc.associations.include?(new_i_name)
                  voc.associations[new_i_name].concat(keep_assocs)
                else
                  voc.associations[new_i_name] = keep_assocs
                end
              end
              voc.associations.delete(old_i_name)
            end
            next unless voc.respond_to?(:vars) && voc.vars.include?(a_var.name)

            user_names = voc.ivars[old_i_name]
            unseen = user_names.reject { |nm| old_names.include?(nm) }
            unseen.each do |usr_name|
              new_var = name2var(usr_name)
              fused_vars << new_var
            end
            unless voc.ivars.include?(new_i_name)
              voc.ivars[new_i_name] = user_names
            else
              voc.ivars[new_i_name].merge(user_names)
            end
            voc.ivars.delete(old_i_name)
            break
          end
          a_var.i_name = new_i_name
        end
      end

      # @param var [Variable, VariableRef] the variable to check.
      # @return [Boolean]
      def fresh?(var)
        ground_term = ground_value(var)
        ground_term.nil? ? true : false
      end

      # @param var [Variable, VariableRef] variable for which the value to retrieve
      # @return [Term, NilClass]
      def ground_value(var)
        name = var.respond_to?(:var_name) ? var.var_name : var.name

        walker = AssociationWalker.new
        walker.find_ground(name, self)
      end

      # @param val [CompositeTerm] the composite term to check.
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

      # Return the variable with given user-defined variable name.
      # @param aName [String] User-defined variable name
      def name2var(aName)
        var = nil
        walker = ancestor_walker

        loop do
          voc = walker.next
          if voc
            next unless voc.respond_to?(:vars) && voc.vars.include?(aName)

            var = voc.vars[aName]
          end

          break
        end

        var
      end

      # Return the variable with given internal variable name.
      # @param i_name [String] internal variable name
      # @return [Variable]
      def i_name2var(i_name)
        var = nil
        voc = nil
        walker = ancestor_walker

        loop do
          voc = walker.next
          if voc
            next unless voc.respond_to?(:ivars) && voc.ivars.include?(i_name)

            var_name = voc.ivars[i_name].first # TODO: what if multiple vars?
            var = voc.vars[var_name]
          end

          break
        end

        raise StandardError, 'Nil variable object' if var.nil?

        var
      end

      # Return the internal name to corresponding to a given user-defined
      #   variable name.
      # @param aName [String] User-defined variable name
      def to_internal(aName)
        var = name2var(aName)
        var ? var.i_name : nil
      end

      # Return the internal names fused with given user-defined
      #   variable name.
      # @param aName [String] User-defined variable name
      def names_fused(aName)
        # require 'debug'
        var = name2var(aName)
        return [] unless var&.fused?

        i_name = var.i_name
        names = []
        walker = ancestor_walker

        loop do
          voc = walker.next
          break unless voc
          next unless voc.respond_to?(:ivars)

          if voc.ivars.include?(i_name)
            fused = voc.ivars[i_name]
            names.concat(fused.to_a)
          end
        end

        names.uniq!
        names.reject { |nm| nm == aName }
      end

      # Retrieve all the associations for a given variable
      # @param aVariable [Variable]
      # @return [Array<Association>]
      def assocs4var(aVariable)
        i_name = aVariable.i_name
        assocs = []
        walker = ancestor_walker

        loop do
          voc = walker.next
          break unless voc
          next unless voc.associations.include?(i_name)

          assocs.concat(voc.associations[i_name])
        end

        assocs
      end

      # @param aName [String] User-defined variable name
      # @return [Array<Association>]
      def [](aName)
        iname = to_internal(aName)
        return [] unless iname

        assoc_arr = associations[iname]
        assoc_arr = [] if assoc_arr.nil?

        # TODO: Optimize
        assoc_arr.concat(parent[aName]) if parent
        assoc_arr
      end

      # Check that a variable with given name is defined in this vocabulary
      # or one of its ancestor.
      # @param aVarName [String] A user-defined variable name.
      # @return [Boolean]
      def include?(aVarName)
        name2var(aVarName) ? true : false
      end

      def prune(anOutcome)
        anOutcome # Don't touch outcome
      end

      def inspect
        result = +"#<#{self.class.name}:#{object_id.to_s(16)} @parent="
        if parent
          result << "#<#{parent.class.name}:#{parent.object_id.to_s(16)}>"
        else
          result << 'nil'
        end
        result << introspect
        result << '>'
        result
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

      # @param theAssociations [Array<Association>]
      def do_add_assocs(theAssociations)
        theAssociations.each do |assc|
          i_name = assc.i_name
          found_assocs = associations[i_name]
          if found_assocs
            found_assocs << assc
          else
            associations[i_name] = [assc]
          end

          assc
        end
      end

      def introspect
        ''
      end
    end # class
  end # module
end # module
