require_relative 'term'
require_relative 'freshness'

module MiniKraken
  module Core
    # An composite term is an Minikraken term that can be
    # decomposed into simpler MiniKraken data value(s).
    class CompositeTerm < Term

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

      # # Data equality testing
      # # @return [Boolean]
      # def ==(other)
        # if other.respond_to?(:value)
          # value == other.value
        # else
          # value == other
        # end
      # end

      # # Type and data equality testing
      # # @return [Boolean]
      # def eql?(other)
        # (self.class == other.class) && value.eql?(other.value)
      # end
    end # class
  end # module
end # module