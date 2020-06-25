# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/disj2'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/formal_arg'
require_relative '../../lib/mini_kraken/core/formal_ref'
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/goal_template'
require_relative '../../lib/mini_kraken/core/k_symbol'
require_relative '../../lib/mini_kraken/core/variable_ref'
require_relative '../../lib/mini_kraken/core/environment'

# Load the class under test
require_relative '../../lib/mini_kraken/core/def_relation'

module MiniKraken
  module Core
    describe DefRelation do
      let(:tea) { KSymbol.new(:tea) }
      let(:formal_t) { FormalArg.new('t') }
      let(:t_ref) { FormalRef.new('t') }
      let(:equals_tea) { GoalTemplate.new(Equals.instance, [tea, t_ref]) }
      subject { DefRelation.new('teao', equals_tea, [formal_t]) }

      context 'Initialization:' do
        it 'should be initialized with a name, a goal template, formal args' do
          expect { DefRelation.new('teao', equals_tea, [formal_t]) }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('teao')
        end

        it 'should know its goal template' do
          expect(subject.goal_template).to eq(equals_tea)
        end

        it 'should know its formals' do
          expect(subject.formals).to eq([formal_t])
        end
      end # context

      context 'Provided services:' do
        let(:cup) { KSymbol.new(:cup) }
        let(:ref_x) { VariableRef.new('x') }
        let(:equals_cup) { GoalTemplate.new(Equals.instance, [cup, t_ref]) }
        let(:g_template) { GoalTemplate.new(Disj2.instance, [equals_tea, equals_cup]) }
        subject { DefRelation.new('teacup', g_template, [formal_t]) }
        let(:env) { Environment.new }

        it 'should provide solver for a single-node goal without var ref' do
          defrel = DefRelation.new('teao', equals_tea, [formal_t])
          solver = defrel.solver_for([tea], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          outcome = solver.resume
          expect(outcome).to be_nil

          solver = defrel.solver_for([cup], env)
          outcome = solver.resume
          expect(outcome).not_to be_successful
          outcome = solver.resume
          expect(outcome).to be_nil
        end

        it 'should provide solver for a single-node goal' do
          defrel = DefRelation.new('teao', equals_tea, [formal_t])
          env.add_var(Variable.new('x'))
          solver = defrel.solver_for([ref_x], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(ref_x.value(outcome)).to eq(tea)

          outcome = solver.resume
          expect(outcome).to be_nil
        end

        it 'should provide solver for a single-node goal' do
          env.add_var(Variable.new('x'))
          solver = subject.solver_for([ref_x], env)
          outcome = solver.resume
          expect(outcome).to be_successful
          expect(ref_x.value(outcome)).to eq(tea)

          outcome = solver.resume
          expect(outcome).to be_successful
          expect(ref_x.value(outcome)).to eq(cup)

          outcome = solver.resume
          expect(outcome).to be_nil
        end
      end # context
    end # describe
  end # module
end # module
