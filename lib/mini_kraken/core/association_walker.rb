# frozen_string_literal: true

require 'set'
require_relative '../atomic/atomic_term'
require_relative '../composite/cons_cell'

module MiniKraken
  module Core
    class AssociationWalker
      attr_reader :visitees

      def initialize
        @visitees = Set.new
      end

      # @param aName [String]
      # @param anEnv [Vocabulary]
      # @return [Term, NilClass]
      def find_ground(aName, anEnv)
        # require 'debug'
        assocs = anEnv[aName]
        walk_assocs(assocs, anEnv)
      end

      def walk_assocs(assocs, anEnv)
        # Treat easy cases first...
        return nil if assocs.empty?

        assoc_atomic = assocs.find { |assc| assc.value.kind_of?(Atomic::AtomicTerm) }
        return assoc_atomic.value if assoc_atomic

        result = nil
        assocs.each do |assc|
          unless visitees.include?(assc)
            visitees.add(assc)
            sub_result = walk_value(assc.value, anEnv)
            if sub_result
              result = sub_result
              break
            end
          end
        end

        result
      end

      def walk_value(aTerm, anEnv)
        return aTerm if aTerm.kind_of?(Atomic::AtomicTerm) || aTerm.kind_of?(AnyValue)

        result = nil

        if aTerm.kind_of?(Composite::CompositeTerm)
          children = aTerm.children.compact
          walk_results = children.map do |child|
            walk_value(child, anEnv)
          end
          result = aTerm unless walk_results.any?(&:nil?)
        else # LogVarRef or Variable
          name = aTerm.respond_to?(:name) ? aTerm.name : aTerm.var_name
          result = find_ground(name, anEnv)
        end

        result
      end

      # A composite term is fresh when all its members are nil or all non-nil members
      # are all fresh.
      # A composite term is bound when it is not fresh and not ground
      # A composite term is a ground term when all its non-nil members are ground.
      # @param aTerm [Term]
      # @param anEnv [Vocabulary]
      # @return [Freshness]
      def determine_freshness(aTerm, anEnv)
        # require 'debug'
        result = nil

        if aTerm.kind_of?(Atomic::AtomicTerm)
          result = Freshness.new(:ground, aTerm)
        elsif aTerm.kind_of?(Composite::CompositeTerm)
          children = aTerm.children.compact
          walk_results = children.map { |chd| determine_freshness(chd, anEnv) }

          degree = nil
          if walk_results.all?(&:fresh?)
            degree = :fresh
          elsif walk_results.all?(&:ground?)
            degree = :ground
          else
            degree = :bound
          end
          result = Freshness.new(degree, aTerm)
        else # LogVarRef or Variable
          name = aTerm.respond_to?(:name) ? aTerm.name : aTerm.var_name
          assocs = anEnv[name]
          if assocs.empty?
            result = Freshness.new(:fresh, nil)
          else
            result = freshness_associated(assocs, anEnv)
          end
        end

        result
      end

      def freshness_associated(assocs, anEnv)
        assoc_atomic = assocs.find { |assc| assc.value.kind_of?(Atomic::AtomicTerm) }
        return Freshness.new(:ground, assoc_atomic.value) if assoc_atomic

        raw_results = assocs.map do |assc|
          unless visitees.include?(assc)
            visitees.add(assc)
            determine_freshness(assc.value, anEnv)
          end
        end

        raw_results.compact!
        result = nil
        if raw_results.all?(&:fresh?)
          # TODO: What if multiple bindings?...
          result = Freshness.new(:bound, assocs[0].value)
        elsif raw_results.any?(&:ground?)
          ground_value = raw_results.find(&:ground?).associated
          result = Freshness.new(:ground, ground_value)
        else
          # TODO: What if multiple bindings?...
          result = Freshness.new(:bound, raw_results[0].associated)
        end

        result
      end

      def quote_term(aTerm, anEnv)
        # require 'debug'
        result = nil

        if aTerm.kind_of?(Atomic::AtomicTerm)
          result = aTerm.quote(anEnv)
        elsif aTerm.kind_of?(Composite::ConsCell)
          result = aTerm.quote(anEnv)
        else # LogVarRef or Variable
          name = aTerm.respond_to?(:name) ? aTerm.name : aTerm.var_name
          assocs = anEnv[name]
          if assocs.empty?
            result = nil
          else
            result = quote_associated(assocs, anEnv)
          end
        end

        result
      end

      def quote_associated(assocs, anEnv)
        assoc_atomic = assocs.find { |assc| assc.value.kind_of?(Atomic::AtomicTerm) }
        return assoc_atomic.value if assoc_atomic

        raw_results = assocs.map do |assc|
          unless visitees.include?(assc)
            visitees.add(assc)
            quote_term(assc.value, anEnv)
          end
        end

        raw_results.compact!
        result = nil
        if raw_results.empty?
          result = nil
        elsif raw_results.all? { |res| res.fresh?(anEnv) }
          # TODO: What if multiple bindings?...
          result = quote_term(assocs[0].value, anEnv)
        elsif raw_results.any? { |res| res.ground?(anEnv) }
          ground_res = raw_results.find { |res| res.ground?(anEnv) }
          result = quote_term(ground_res, anEnv)
        else
          # TODO: What if multiple bindings?...
          result = quote_term(raw_results[0], anEnv)
        end

        result
      end
    end # class
  end # module
end # module
