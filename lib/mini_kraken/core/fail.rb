# frozen_string_literal: true

require 'singleton'
require_relative 'duck_fiber'
require_relative 'nullary_relation'

unless MiniKraken::Core.constants(false).include? :Fail
  module MiniKraken
    module Core
      # A nullary relation that unconditionally always fails.
      class Fail < NullaryRelation
        include Singleton

        def initialize
          super('fail', '#u')
        end

        # @return [DuckFiber]
        def solver_for(_actuals, _env)
          DuckFiber.new(:failure)
        end
      end # class

      Fail.instance.freeze
    end # module
  end # module
end # unless
