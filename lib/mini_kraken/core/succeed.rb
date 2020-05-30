# frozen_string_literal: true

require 'singleton'
require_relative 'duck_fiber'
require_relative 'nullary_relation'

unless MiniKraken::Core.constants(false).include? :Succeed
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

      Succeed.instance.freeze
    end # module
  end # module
end # unless
