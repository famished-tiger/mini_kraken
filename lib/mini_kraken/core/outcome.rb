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

        def successful?
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
