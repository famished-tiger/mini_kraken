# frozen_string_literal: true

require_relative 'vocabulary'

unless MiniKraken::Core.constants(false).include? :Outcome
  module MiniKraken
    module Core
      class Outcome
        include Vocabulary # Use mix-in module

        # @return [Symbol] One of: :"#s" (success), :"#u" (failure)
        attr_reader :resultant

        def initialize(aResult, aParent = nil)
          init_vocabulary(aParent)
          @resultant = aResult
        end

        def self.failure(aParent = nil)
          new(:"#u", aParent)
        end

        def self.success(aParent = nil)
          new(:"#s", aParent)
        end

        def failure?
          resultant != :"#s"
        end

        def success?
          resultant == :"#s"
        end

        def ==(other)
          are_equal = false

          if resultant == other.resultant && parent == other.parent &&
             associations == other.associations
            are_equal = true
          end

          are_equal
        end

        # Remove associations of variables of this environment, if
        # persistence flag is set to false.
        def prune!
          parent.prune(self)
        end

        protected

        def introspect
          ", @resultant=#{resultant}"
        end
      end # class

      Failure = Outcome.new(:"#u")
      BasicSuccess = Outcome.new(:"#s")
    end # module
  end # module
end # defined
