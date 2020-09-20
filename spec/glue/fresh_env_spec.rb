# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/atomic/k_symbol'
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/succeed'

# Load the class under test
require_relative '../../lib/mini_kraken/glue/fresh_env'


module MiniKraken
  module Glue
    describe FreshEnv do
      let(:pea) { Atomic::KSymbol.new(:pea) }
      let(:pod) { Atomic::KSymbol.new(:pod) }
      let(:sample_goal) do
        Core::Goal.new(Core::Equals.instance, [pea, pod])
      end
      let(:pea_goal) do
        Core::Goal.new(Core::Equals.instance, [pea, pea])
      end
      let(:goal_succeeds) { Core::Goal.new(Core::Succeed.instance, []) }
      let(:goal_fails) { Core::Goal.new(Core::Fail.instance, []) }
      subject { FreshEnv.new(['q'], sample_goal) }

      context 'Initialization:' do
        it 'could be initialized with names and a goal' do
          expect { FreshEnv.new(['q'], sample_goal) }.not_to raise_error
        end

        it 'could be  initialized with names and goals' do
          expect { FreshEnv.new(%w[x y], [pea_goal, goal_succeeds]) }.not_to raise_error
        end

        it 'should know its variables' do
          expect(subject.vars['q']).not_to be_nil

          instance = FreshEnv.new(%w[x y], sample_goal)
          expect(instance.vars['x']).not_to be_nil
          expect(instance.vars['y']).not_to be_nil
        end

        it 'should know its goal' do
          # Single goal at initialization
          expect(subject.goal).to eq(sample_goal)

          # Multiple goals at initialization
          instance = FreshEnv.new(['q'], [pea_goal, goal_succeeds])
          expect(instance.goal.relation.name).to eq('conj2')
          expect(instance.goal.actuals[0]).to eq(pea_goal)
          expect(instance.goal.actuals[1]).to eq(goal_succeeds)
        end
      end # context

      context 'Provided services:' do
      end # context
    end # describe
  end # module
end # module
