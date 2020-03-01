require_relative 'variable'
require_relative 'run_star_expression'

module MiniKraken
  module Core
    class Facade
      attr_reader :publisher
      def initialize(aPublisher)
        @publisher = aPublisher
      end

      def run_star(theVariables, aGoal)
        tuple = build_tuple(theVariables)

        expr = RunStarExpression.new(tuple, aGoal)
        expr.run(publisher)
      end

      private

      def build_tuple(theVariables)
        tuple = nil
        if theVariables.kind_of?(Array)
          tuple = theVariables.map { |v| build_single_var(v) }
        else
          tuple = [build_single_var(theVariables)]
        end

        tuple
      end

      def build_single_var(aVar)
        var = nil
        case aVar
          when Symbol
            var = Variable.new(aVar.to_s)
          when String
            var = Variable.new(aVar)
        end

        var
      end
    end # class
  end # module
end # module