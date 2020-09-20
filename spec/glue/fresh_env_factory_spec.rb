# frozen_string_literal: true

require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/formal_arg'
require_relative '../../lib/mini_kraken/core/formal_ref'
require_relative '../../lib/mini_kraken/core/goal_template'

require_relative '../support/factory_atomic'
require_relative '../support/factory_methods'

# Load the class under test
require_relative '../../lib/mini_kraken/glue/fresh_env_factory'


module MiniKraken
  module Glue
    describe FreshEnvFactory do
      include MiniKraken::FactoryAtomic # Use mix-in module
      include FactoryMethods

      # (fresh (d) (== d r))
      let(:r_formal_ref) { Core::FormalRef.new('r') }
      let(:d_ref) { var_ref('d') }
      let(:sample_goal_t) do
        Core::GoalTemplate.new(Core::Equals.instance, [d_ref, r_formal_ref])
      end
      subject { FreshEnvFactory.new(['d'], sample_goal_t) }

      context 'Initialization:' do
        it 'should be initialized with names and a goal template' do
          expect { FreshEnvFactory.new(['d'], sample_goal_t) }.not_to raise_error
        end

        it 'should know the variable names' do
          expect(subject.names).to eq(['d'])
        end

        it 'should know the goal template' do
          expect(subject.goal_template).to eq(sample_goal_t)
        end
      end # context

      context 'Factory for FreshEnv instances' do
        # (defrel (caro r a)
        #   (fresh (d)
        #   (== (cons a d) r)))
        # ;; r, a are formal args, they part of caro signature
        # ;; d is a formal ref argument
        let(:pea) { k_symbol(:pea) }
        let(:q_ref) { var_ref('q') }
        let(:r_formal) { Core::FormalRef.new('r') }
        let(:a_formal) { Core::FormalRef.new('a') }
        let(:t_param1) { Composite::ConsCell.new(a_formal, d_ref) }
        let(:other_goal_t) do
          Core::GoalTemplate.new(Core::Equals.instance, [t_param1, r_formal])
        end

        # (fresh (d) (== d r))
        it 'should build FreshEnv instance with simple goal' do
          created = subject.instantiate([r_formal], [pea])

          # Are variables correctly built?
          expect(created).to be_kind_of(FreshEnv)
          expect(created.vars['d']).to be_kind_of(Core::LogVar)

          # Is the goal correectly built?
          goal = created.goal
          expect(goal.relation).to eq(Core::Equals.instance)
          expect(goal.actuals[0]).to be_kind_of(Core::LogVarRef)
          expect(goal.actuals[0].name).to eq('d')
          expect(goal.actuals[1]).to be_kind_of(Atomic::KSymbol)
          expect(goal.actuals[1]).to eq(:pea)
        end

        it 'should build FreshEnv instance with goal' do
          instance = FreshEnvFactory.new(['d'], other_goal_t)
          acorn = cons(k_symbol(:a), cons(k_symbol(:c), cons(k_symbol(:o),
            cons(k_symbol(:r), cons(k_symbol(:n))))))
          created = instance.instantiate([r_formal, a_formal], [acorn, q_ref])

          # Are variables correctly built?
          expect(created).to be_kind_of(FreshEnv)
          expect(created.vars['d']).to be_kind_of(Core::LogVar)

          # Is the goal correctly built?
          goal = created.goal
          expect(goal.relation).to eq(Core::Equals.instance)
          expect(goal.actuals[0]).to be_kind_of(Composite::ConsCell)
          expect(goal.actuals[0].car).to be_kind_of(Core::LogVarRef)
          expect(goal.actuals[0].car.name).to eq('q')
          expect(goal.actuals[0].cdr).to be_kind_of(Core::LogVarRef)
          expect(goal.actuals[0].cdr.name).to eq('d')
          expect(goal.actuals[1]).to be_kind_of(Composite::ConsCell)
          expect(goal.actuals[1].to_s).to eq('(:a :c :o :r :n)')
        end
      end # context
    end # describe
  end # module
end # module
