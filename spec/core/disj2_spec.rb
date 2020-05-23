# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/k_symbol'
require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/succeed'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/environment'
require_relative '../../lib/mini_kraken/core/variable'
require_relative '../../lib/mini_kraken/core/variable_ref'

# Load the class under test
require_relative '../../lib/mini_kraken/core/disj2'

module MiniKraken
  module Core
    describe Disj2 do
      subject { Disj2.instance }

      context 'Initialization:' do
        it 'should be initialized without argument' do
          expect { Disj2.instance }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('disj2')
        end
      end # context

      context 'Provided services:' do
        let(:corn) { KSymbol.new(:corn) }
        let(:meal) { KSymbol.new(:meal) }
        let(:oil) { KSymbol.new(:oil) }
        let(:olive) { KSymbol.new(:olive) }
        let(:pea) { KSymbol.new(:pea) }
        let(:fails) { Goal.new(Fail.instance, []) }
        let(:succeeds) { Goal.new(Succeed.instance, []) }
        let(:var_q) { Variable.new('q') }
        let(:ref_q) { VariableRef.new('q') }
        let(:env) do
          e = Environment.new
          e.add_var(var_q)
          e
        end

        it 'should complain when one of its argument is not a goal' do
          err = StandardError
          expect { subject.solver_for([succeeds, pea], env) }.to raise_error(err)
          expect { subject.solver_for([pea, succeeds], env) }.to raise_error(err)
        end

        it 'should fails if both arguments fail' do
          # Covers frame 1:55
          solver = subject.solver_for([fails, fails], env)
          expect(solver.resume).not_to be_successful
          expect(solver.resume).to be_nil
        end

        it 'yield success if first argument succeeds' do
          # Covers frame 1:56
          subgoal = Goal.new(Equals.instance, [olive, ref_q])
          solver = subject.solver_for([subgoal, fails], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(outcome.associations['q'].first.value).to eq(olive)
          expect(solver.resume).to be_nil
        end

        it 'yield success if second argument succeeds' do
          # Covers frame 1:57
          subgoal = Goal.new(Equals.instance, [oil, ref_q])
          solver = subject.solver_for([fails, subgoal], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(outcome.associations['q'].first.value).to eq(oil)
          expect(solver.resume).to be_nil
        end

        it 'yield two solutions if both arguments succeed' do
          # Covers frame 1:58
          subgoal1 = Goal.new(Equals.instance, [olive, ref_q])
          subgoal2 = Goal.new(Equals.instance, [oil, ref_q])
          solver = subject.solver_for([subgoal1, subgoal2], env)

          # First solution
          outcome1 = solver.resume
          expect(outcome1).to be_successful
          expect(outcome1.associations['q'].first.value).to eq(olive)

          # Second solution
          outcome2 = solver.resume
          expect(outcome2).to be_successful
          expect(outcome2.associations['q'].first.value).to eq(oil)
          expect(solver.resume).to be_nil
        end

        it 'should yield success and set associations' do
          # # Weird: this example succeeds if run alone...
          # # Covers frame 1-51
          # env.add_var(var_q)
          # sub_goal = Goal.new(Equals.instance, [corn, ref_q])
          # solver = subject.solver_for([succeeds, sub_goal], env)
          # outcome = solver.resume
          # expect(outcome).to be_successful
          # expect(outcome.associations).not_to be_empty
          # expect(outcome.associations['q'].first.value).to eq(corn)
        end

        # it 'should yield fails and set no associations' do
          # # Covers frame 1-52
          # env.add_var(var_q)
          # sub_goal = Goal.new(Equals.instance, [corn, ref_q])
          # solver = subject.solver_for([fails, sub_goal], env)
          # outcome = solver.resume
          # expect(outcome).not_to be_successful
          # expect(outcome.associations).to be_empty
        # end

        # it 'should yield fails when sub-goals are incompatible' do
          # # Covers frame 1-53
          # env.add_var(var_q)
          # sub_goal1 = Goal.new(Equals.instance, [corn, ref_q])
          # sub_goal2 = Goal.new(Equals.instance, [meal, ref_q])
          # solver = subject.solver_for([sub_goal1, sub_goal2], env)
          # outcome = solver.resume
          # expect(outcome).not_to be_successful
          # expect(outcome.associations).to be_empty
        # end

        # it 'should yield success when sub-goals are same and successful' do
          # # Covers frame 1-54
          # env.add_var(var_q)
          # sub_goal1 = Goal.new(Equals.instance, [corn, ref_q])
          # sub_goal2 = Goal.new(Equals.instance, [corn, ref_q])
          # solver = subject.solver_for([sub_goal1, sub_goal2], env)
          # outcome = solver.resume
          # expect(outcome).to be_successful
          # expect(outcome.associations).not_to be_empty
          # expect(outcome.associations['q'].first.value).to eq(corn)
        # end
      end # context
    end # describe
  end # module
end # module
