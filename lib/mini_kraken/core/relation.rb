module MiniKraken
  module Core
    class Relation
      # @return [String] Name of the relation.
      attr_reader :name

      # @return [String, NilClass] Optional alternative name of the relation.
      attr_reader :alt_name

      # @param aName [String] Name of the relation.
      # @param alternateName [String, NilClass] Alternative name (optional).
      def initialize(aName, alternateName = nil)
        @name = aName
        @alt_name = alternateName
      end

      # Number of arguments for the relation.
      # @return [Integer]
      def arity
        raise NotImplementedError
      end

      # Attempt to achieve the goal for a given context (environment)
      # @param anEnv [Environment] The context in which the goal take place.
      # @return [Fiber<Outcome>] A Fiber object that will generate the results.
      # def solve(args, anEnv)
       # Fiber instance responds to resume(*args) message
        # If too much resume calls => FiberError: dead fiber called message.

        # Fiber.new do |first_yield_arg| do
          # begin
            # result = relation.solve(actuals, anEnv)
            # Fiber.yield result
          # while result.success?

          nil
      # end

      def inspect
        alt_name ? alt_name : name
      end
    end # class
  end # module
end # module