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
require_relative '../../lib/mini_kraken/core/conj2'


module MiniKraken
  module Core
    describe Conj2 do
      subject { Conj2.instance }

      context 'Initialization:' do
        it 'should be initialized without argument' do
          expect { Conj2.instance }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('conj2')
        end
      end # context

      context 'Provided services:' do
        let(:env) { Environment.new }
        let(:pea) { KSymbol.new(:pea) }
        let(:corn) { KSymbol.new(:corn) }
        let(:meal) { KSymbol.new(:meal) }
        let(:fails) { Goal.new(Fail.instance, []) }
        let(:succeeds) { Goal.new(Succeed.instance, []) }
        let(:var_q) { Variable.new('q') }
        let(:ref_q) { VariableRef.new('q') }

        it 'should complain when one of its argument is not a goal' do
          err = StandardError
          expect { subject.solver_for([succeeds, pea], env) }.to raise_error(err)
          expect { subject.solver_for([pea, succeeds], env) }.to raise_error(err)
        end

        it 'should yield one failure if one of the goal is fail' do
          # Fail as first argument
          solver = subject.solver_for([fails, succeeds], env)
          expect(solver.resume).not_to be_success
          expect(solver.resume).to be_nil

          # Fail as second argument
          solver = subject.solver_for([succeeds, fails], env)
          expect(solver.resume).not_to be_success
          expect(solver.resume).to be_nil
        end

        it 'yield success if both arguments are succeed goals' do
          # Covers frame 1-50
          solver = subject.solver_for([succeeds, succeeds], env)
          outcome = solver.resume
          expect(outcome).to be_success
          expect(outcome.associations).to be_empty
          expect(solver.resume).to be_nil
        end

        it 'should yield success and set associations' do
          # Covers frame 1-51
          env.add_var(var_q)
          sub_goal = Goal.new(Equals.instance, [corn, ref_q])
          solver = subject.solver_for([succeeds, sub_goal], env)
          outcome = solver.resume
          expect(outcome).to be_success
          expect(outcome.associations).not_to be_empty
          expect(outcome.associations['q'].first.value).to eq(corn)
        end

        it 'should yield fails and set no associations' do
          # Covers frame 1-52
          env.add_var(var_q)
          sub_goal = Goal.new(Equals.instance, [corn, ref_q])
          solver = subject.solver_for([fails, sub_goal], env)
          outcome = solver.resume
          expect(outcome).not_to be_success
          expect(outcome.associations).to be_empty
        end

        it 'should yield fails when sub-goals are incompatible' do
          # Covers frame 1-53
          env.add_var(var_q)
          sub_goal1 = Goal.new(Equals.instance, [corn, ref_q])
          sub_goal2 = Goal.new(Equals.instance, [meal, ref_q])
          solver = subject.solver_for([sub_goal1, sub_goal2], env)
          outcome = solver.resume
          expect(outcome).not_to be_success
          expect(outcome.associations).to be_empty
        end

        it 'should yield success when sub-goals are same and successful' do
          # Covers frame 1-54
          env.add_var(var_q)
          sub_goal1 = Goal.new(Equals.instance, [corn, ref_q])
          sub_goal2 = Goal.new(Equals.instance, [corn, ref_q])
          solver = subject.solver_for([sub_goal1, sub_goal2], env)
          outcome = solver.resume
          expect(outcome).to be_success
          expect(outcome.associations).not_to be_empty
          expect(outcome.associations['q'].first.value).to eq(corn)
        end
      end # context
    end # describe
  end # module
end # module
