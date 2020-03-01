module MiniKraken
  module Core
    class RunStarExpression
      attr_reader :vars
      attr_reader :goal

      def initialize(theVariables, aGoal)
        @vars = validated_vars(theVariables)
        @goal = aGoal
      end
      
      def run(aPublisher)
        goal.attain(aPublisher, vars)
      end

      private

      def validated_vars(theVariables)
        variables = {} 
        case theVariables
          when Variable
            variables[theVariables.name] = theVariables

          when Array
            theVariables.each { |v| variables[v.name] = v }
          else
            raise StandardError, "Invalid argument #{p theVariables}"
        end
        
        variables
      end
    end # class
  end # module
end # module