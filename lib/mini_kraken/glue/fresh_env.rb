require_relative '../core/environment'
require_relative '../core/variable'

module MiniKraken
  module Glue
    # (fresh (x) (== 'pea q))
    # Introduces the new variable 'x'
    # Takes a list of names and a goal-like object
    # Must respond to message attain(aPublisher, vars) and must return an Outcome
    class FreshEnv < Core::Environment
      # @return [Goal]
      attr_reader :goal

      # @param theNames [Array<String>]
      # @param aGoal [Goal]
      def initialize(theNames, aGoal)
        super()
        @goal = aGoal
        theNames.each { |nm| add_var(Core::Variable.new(nm)) }
      end

      # Attempt to achieve the goal given this environment
      # @param aParent [Environment] 
      # @return [Fiber<Outcome>] A Fiber object that will generate the results.      
      def attain(aParent)
        self.parent = aParent
        goal.attain(self)
      end
    end # class
  end # module
end # module