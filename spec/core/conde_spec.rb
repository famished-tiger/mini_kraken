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
require_relative '../../lib/mini_kraken/core/conde'

module MiniKraken
  module Core
    describe Conde do
      subject { Conde.instance }

      context 'Initialization:' do
        it 'should be initialized without argument' do
          expect { Conde.instance }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('conde')
        end
      end # context

      context 'Provided services:' do
        let(:bean) { KSymbol.new(:bean) }
        let(:corn) { KSymbol.new(:corn) }
        let(:meal) { KSymbol.new(:meal) }
        let(:oil) { KSymbol.new(:oil) }
        let(:olive) { KSymbol.new(:olive) }
        let(:pea) { KSymbol.new(:pea) }
        let(:red) { KSymbol.new(:red) }
        let(:split) { KSymbol.new(:split) }
        let(:fails) { Goal.new(Fail.instance, []) }
        let(:succeeds) { Goal.new(Succeed.instance, []) }
        let(:var_q) { Variable.new('q') }
        let(:var_x) { Variable.new('x') }
        let(:var_y) { Variable.new('y') }
        let(:ref_q) { VariableRef.new('q') }
        let(:ref_x) { VariableRef.new('x') }
        let(:ref_y) { VariableRef.new('y') }
        let(:env) do
          e = Environment.new
          e.add_var(var_q)
          e.add_var(var_x)
          e.add_var(var_y)
          e
        end

        it 'should complain when one of its argument is not a goal' do
          err = StandardError
          expect { subject.solver_for([succeeds, pea], env) }.to raise_error(err)
          expect { subject.solver_for([pea, succeeds], env) }.to raise_error(err)
        end

        it 'should fail when all goals fail' do
          solver = subject.solver_for([fails, fails, fails], env)
          expect(solver.resume).not_to be_successful
          expect(solver.resume).to be_nil
        end

        it 'yield success if first argument succeeds' do
          subgoal = Goal.new(Equals.instance, [olive, ref_q])
          solver = subject.solver_for([subgoal, fails, fails], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(outcome.associations['q'].first.value).to eq(olive)
          expect(solver.resume).to be_nil
        end

        it 'yield success if second argument succeeds' do
          subgoal = Goal.new(Equals.instance, [oil, ref_q])
          solver = subject.solver_for([fails, subgoal, fails], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(outcome.associations['q'].first.value).to eq(oil)
          expect(solver.resume).to be_nil
        end

        it 'yield success if third argument succeeds' do
          subgoal = Goal.new(Equals.instance, [oil, ref_q])
          solver = subject.solver_for([fails, fails, subgoal], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(outcome.associations['q'].first.value).to eq(oil)
          expect(solver.resume).to be_nil
        end

        it 'yields three solutions if three goals succeed' do
          # Covers frame 1:58
          subgoal1 = Goal.new(Equals.instance, [olive, ref_q])
          subgoal2 = Goal.new(Equals.instance, [oil, ref_q])
          subgoal3 = Goal.new(Equals.instance, [pea, ref_q])
          solver = subject.solver_for([subgoal1, subgoal2, subgoal3, fails], env)

          # First solution
          outcome1 = solver.resume
          expect(outcome1).to be_successful
          expect(outcome1.associations['q'].first.value).to eq(olive)

          # Second solution
          outcome2 = solver.resume
          expect(outcome2).to be_successful
          expect(outcome2.associations['q'].first.value).to eq(oil)

          # Third solution
          outcome3 = solver.resume
          expect(outcome3).to be_successful
          expect(outcome3.associations['q'].first.value).to eq(pea)

          expect(solver.resume).to be_nil
        end

        it 'also use conjunctions for nested goals' do
          # Covers frame 1:88
          subgoal1 = Goal.new(Equals.instance, [split, ref_x])
          subgoal2 = Goal.new(Equals.instance, [pea, ref_y])
          combo1 = [subgoal1, subgoal2]

          subgoal3 = Goal.new(Equals.instance, [red, ref_x])
          subgoal4 = Goal.new(Equals.instance, [bean, ref_y])
          combo2 = [subgoal3, subgoal4]
          solver = subject.solver_for([combo1, combo2], env)

          # First solution
          outcome1 = solver.resume
          expect(outcome1).to be_successful
          expect(outcome1.associations['x'].first.value).to eq(split)
          expect(outcome1.associations['y'].first.value).to eq(pea)

          # Second solution
          outcome2 = solver.resume
          expect(outcome2).to be_successful
          expect(outcome2.associations['x'].first.value).to eq(red)
          expect(outcome2.associations['y'].first.value).to eq(bean)

          expect(solver.resume).to be_nil
        end
      end # context
    end # describe
  end # module
end # module
