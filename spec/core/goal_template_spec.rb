# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/disj2'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/formal_arg'
require_relative '../../lib/mini_kraken/core/formal_ref'
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/k_symbol'
require_relative '../../lib/mini_kraken/core/variable_ref'
# require_relative '../../lib/mini_kraken/core/environment'

# Load the class under test
require_relative '../../lib/mini_kraken/core/goal_template'


module MiniKraken
  module Core
    describe GoalTemplate do
      let(:tea) { KSymbol.new(:tea) }
      let(:t_ref) { FormalRef.new('t') }
      subject { GoalTemplate.new(Equals.instance, [tea, t_ref]) }

      context 'Initialization:' do
        it 'should be initialized with a relation and args' do
          expect { GoalTemplate.new(Equals.instance, [tea, t_ref]) }.not_to raise_error
        end

        it 'should know its relation' do
          expect(subject.relation).to eq(Equals.instance)
        end

        it 'should know its arguments' do
          expect(subject.args[0]).to eq(tea)
          expect(subject.args[1]).to eq(t_ref)
        end
      end # context

      context 'Provided services:' do
        let(:formal_t) { FormalArg.new('t') }
        let(:cup) { KSymbol.new(:cup) }
        let(:ref_x) { VariableRef.new('x') }
        # let(:env) { Environment.new }

        it 'should instantiate a single-node goal' do
          expect(subject.instantiate([formal_t], [cup])).to be_kind_of(Goal)
          goal = subject.instantiate([formal_t], [cup])
          expect(goal.relation).to eq(Equals.instance)
          expect(goal.actuals[0]).to eq(tea)
          expect(goal.actuals[1]).to eq(cup)
        end

        it 'should instantiate a multiple-nodes goal' do
          sub_tmp1 =  GoalTemplate.new(Equals.instance, [tea, t_ref])
          sub_tmp2 =  GoalTemplate.new(Equals.instance, [cup, t_ref])
          template =  GoalTemplate.new(Disj2.instance, [sub_tmp1, sub_tmp2])

          goal = template.instantiate([formal_t], [ref_x])
          expect(goal.relation).to eq(Disj2.instance)
          subgoal1 = goal.actuals[0]
          expect(subgoal1).to be_kind_of(Goal)
          expect(subgoal1.relation).to eq(Equals.instance)
          expect(subgoal1.actuals[0]).to eq(tea)
          expect(subgoal1.actuals[1]).to eq(ref_x)
          subgoal2 = goal.actuals[1]
          expect(subgoal2).to be_kind_of(Goal)
          expect(subgoal2.relation).to eq(Equals.instance)
          expect(subgoal2.actuals[0]).to eq(cup)
          expect(subgoal2.actuals[1]).to eq(ref_x)
        end
      end # context
    end # describe
  end # module
end # module
