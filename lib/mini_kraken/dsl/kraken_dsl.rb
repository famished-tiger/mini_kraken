require_relative '../core/fail'
require_relative '../core/goal'

module MiniKraken
  module DSL
    module KrakenDSL
      def fail
        Core::Goal.new(Core::Fail.instance, [])
      end
    end # module
  end # module
end # module