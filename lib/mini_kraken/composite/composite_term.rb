# frozen_string_literal: true

require_relative '../core/term'
require_relative '../core/freshness'

module MiniKraken
  # This module packages the composite term classes.
  # These hold one or more MiniKanren objects.
  module Composite
    # An composite term is an Minikraken term that can be
    # decomposed into simpler MiniKraken data value(s).
    class CompositeTerm < Core::Term
      # Abstract method (to override). Return the child terms.
      # @return [Array<Term>]
      def children
        raise NotImplementedError, 'This method must re-defined in subclass(es).'
      end

      # A composite term is fresh when all its members are nil or all non-nil members
      # are all fresh
      # A composite term is bound when it is not fresh and not ground
      # A composite term is a ground term when all its non-nil members are ground.
      # @param _env [Vocabulary]
      # @return [Freshness]
      def freshness(_env)
         env.freshness_composite(self)
      end

      # @param env [Environment]
      # @return [Boolean]
      def fresh?(env)
        env.fresh_value?(self)
      end

      # A composite is ground if all its children are ground
      def ground?(anEnv)
        children.all? do |child|
          child.nil? || child.ground?(anEnv)
        end
      end
    end # class
  end # module
end # module