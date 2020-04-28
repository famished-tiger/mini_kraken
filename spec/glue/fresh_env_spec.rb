# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/k_symbol'

# Load the class under test
require_relative '../../lib/mini_kraken/glue/fresh_env'


module MiniKraken
  module Glue
    describe FreshEnv do
      let(:pea) { Core::KSymbol.new(:pea) }
      let(:pod) { Core::KSymbol.new(:pod) }
      let(:sample_goal) do
        Core::Goal.new(Core::Equals.instance, [pea, pod]) 
      end
      subject { FreshEnv.new(['q'], sample_goal) }

      context 'Initialization:' do
        it 'should be initialized with an array of names' do
          expect { FreshEnv.new(['q'], sample_goal) }.not_to raise_error
        end

        it 'should know its variables' do
          expect(subject.vars['q']).not_to be_nil
        end
      end # context

      context 'Provided services:' do
      end # context
    end # describe
  end # module
end # module
