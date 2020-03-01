require 'singleton'
require_relative 'nullary_relation'

module MiniKraken
  module Core
    class Fail < NullaryRelation
      include Singleton
      
      def initialize
        super('fail')
      end
      
      def unify(aGoal, vars)
        []
      end
    end # class
  end # module
end # module