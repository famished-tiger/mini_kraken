# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../support/factory_atomic'
require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/succeed'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/environment'
require_relative '../../lib/mini_kraken/core/log_var'
require_relative '../../lib/mini_kraken/core/log_var_ref'

# Load the class under test
require_relative '../../lib/mini_kraken/core/disj2'

module MiniKraken
  module Core
    describe Disj2 do
      include MiniKraken::FactoryAtomic # Use mix-in module    
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
        let(:corn) { k_symbol(:corn) }
        let(:meal) { k_symbol(:meal) }
        let(:oil) { k_symbol(:oil) }
        let(:olive) { k_symbol(:olive) }
        let(:pea) { k_symbol(:pea) }
        let(:fails) { Goal.new(Fail.instance, []) }
        let(:succeeds) { Goal.new(Succeed.instance, []) }
        let(:var_q) { LogVar.new('q') }
        let(:ref_q) { LogVarRef.new('q') }
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
          expect(solver.resume).not_to be_success
          expect(solver.resume).to be_nil
        end

        it 'yield success if first argument succeeds' do
          # Covers frame 1:56
          subgoal = Goal.new(Equals.instance, [olive, ref_q])
          solver = subject.solver_for([subgoal, fails], env)
          outcome = solver.resume
          expect(outcome).to be_success
          expect(outcome.associations['q'].first.value).to eq(olive)
          expect(solver.resume).to be_nil
        end

        it 'yield success if second argument succeeds' do
          # Covers frame 1:57
          subgoal = Goal.new(Equals.instance, [oil, ref_q])
          solver = subject.solver_for([fails, subgoal], env)
          outcome = solver.resume
          expect(outcome).to be_success
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
          expect(outcome1).to be_success
          expect(outcome1.associations['q'].first.value).to eq(olive)

          # Second solution
          outcome2 = solver.resume
          expect(outcome2).to be_success
          expect(outcome2.associations['q'].first.value).to eq(oil)
          expect(solver.resume).to be_nil
        end
      end # context
    end # describe
  end # module
end # module
