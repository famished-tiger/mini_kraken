require 'singleton'
require_relative 'duck_fiber'
require_relative 'nullary_relation'

module MiniKraken
  module Core
    # A nullary relation that unconditionally always fails.
    class Succeed < NullaryRelation
      include Singleton

      def initialize
        super('succeed', '#s')
      end
      
      def solver_for(_actuals, _env)
        DuckFiber.new(:success)
      end      
    end # class
  end # module
end # module
