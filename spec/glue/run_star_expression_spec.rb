# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/succeed'

require_relative '../support/factory_methods'

# Load the class under test
require_relative '../../lib/mini_kraken/glue/run_star_expression'


module MiniKraken
  module Glue
    describe RunStarExpression do
      include FactoryMethods
      let(:pea) { k_symbol(:pea) }
      let(:pod) { k_symbol(:pod) }
      let(:sample_goal) { equals_goal(pea, pod) }
      subject { RunStarExpression.new('q', sample_goal) }

      context 'Initialization:' do
        it 'should be initialized with a name and a goal' do
          expect { RunStarExpression.new('q', sample_goal) }.not_to raise_error
        end

        it 'should know its variables' do
          expect(subject.env.vars['q']).not_to be_nil
          expect(subject.var.name).to eq('q')
        end

        it 'should know its goal' do
          expect(subject.env.goal).to eq(sample_goal)
        end
      end # context

      context 'Provided services:' do
        let(:ref_q) { Core::VariableRef.new('q') }
        let(:ref_x) { Core::VariableRef.new('x') }

        it "should return a null list with the fail goal" do
          # Reasoned S2, frame 1:7
          # (run* q #u) ;; => ()
          failing = Core::Goal.new(Core::Fail.instance, [])
          instance = RunStarExpression.new('q', failing)

          expect(instance.run).to be_null
          expect(ref_q.fresh?(instance.env)).to be_truthy
        end

        it "should return a null list when a goal fails" do
          # Reasoned S2, frame 1:10
          # (run* q (== 'pea 'pod) ;; => ()

          expect(subject.run).to be_null
          expect(ref_q.fresh?(subject.env)).to be_truthy
        end

        it 'should unify the variable with the equals goal with symbol' do
          goal = equals_goal(ref_q, pea)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:11
          # (run* q (== q 'pea) ;; => (pea)
          expect(instance.run.car).to eq(pea)
          expect(ref_q.fresh?(instance.env)).to be_falsey
        end

        it 'should unify the righthand variable(s)' do
          goal = equals_goal(pea, ref_q)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:12
          # (run* q (== 'pea q) ;; => (pea)
          expect(instance.run.car).to eq(pea)

          # Reasoned S2, frame 1:15
          expect(ref_q.fresh?(instance.env)).to be_falsey
        end

        it 'should return a null list with the succeed goal' do
          success = Core::Goal.new(Core::Succeed.instance, [])
          instance = RunStarExpression.new('q', success)

          # (display (run* q succeed)) ;; => (_0)
          # Reasoned S2, frame 1:16
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy

          # Reasoned S2, frame 1:17
          expect(result.car).to eq(any_value(0))
        end

        it 'should keep variable fresh when no unification occurs (I)' do
          goal = equals_goal(pea, pea)
          instance = RunStarExpression.new('q', goal)

          # (display (run* q (== 'pea 'pea))) ;; => (_0)
          # Reasoned S2, frame 1:19
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(result.car).to eq(any_value(0))
        end

        it 'should keep variable fresh when no unification occurs (III)' do
          ref1_q = Core::VariableRef.new('q')
          ref2_q = Core::VariableRef.new('q')
          goal = equals_goal(ref1_q, ref2_q)
          instance = RunStarExpression.new('q', goal)

          # (display (run* q (== q q))) ;; => (_0)
          # Reasoned S2, frame 1:20
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(result.car).to eq(any_value(0))
        end

        it 'should accept the nesting of sub-environment' do
          goal = equals_goal(pea, ref_q)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:21..23
          # (run* q (fresh (x) (== 'pea q))) ;; => (pea)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_falsey
          expect(ref_x.fresh?(fresh_env)).to be_truthy
          expect(result.car).to eq(pea)
        end

        it 'should unify nested variables' do
          goal = equals_goal(pea, ref_x)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:24
          # (run* q (fresh (x) (== 'pea x))) ;; => (_0)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(ref_x.fresh?(fresh_env)).to be_falsey
          expect(result.car).to eq(any_value(0))
        end

        it 'should accept expression with variables' do
          goal = equals_goal(cons(ref_x), ref_q)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:25
          # (run* q (fresh (x) (== (cons x '()) q))) ;; => ((_0))
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(ref_x.fresh?(fresh_env)).to be_truthy
          expect(result.car).to eq(cons(any_value(0)))
        end

        it 'should accept fused variables' do
          goal = equals_goal(ref_x, ref_q)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:31
          # (run* q (fresh (x) (== x q))) ;; => (_0)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(ref_x.fresh?(fresh_env)).to be_truthy
          expect(result.car).to eq(any_value(0))
        end

        it 'should cope with complex equality expressions' do
          expr1 = cons(cons(cons(pea)), pod)
          expr2 = cons(cons(cons(pea)), pod)
          goal = equals_goal(expr1, expr2)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:32
          # (run* q (==  '(((pea)) pod) '(((pea)) pod))) ;; => (_0)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(result.car).to eq(any_value(0))
        end

        it 'should unify complex equality expressions (I)' do
          expr1 = cons(cons(cons(pea)), pod)
          expr2 = cons(cons(cons(pea)), ref_q)
          goal = equals_goal(expr1, expr2)
          instance = RunStarExpression.new('q', goal)

          # Beware: quasiquoting
          # Reasoned S2, frame 1:33
          # (run* q (==  '(((pea)) pod) `(((pea)) ,q))) ;; => ('pod)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_falsey
          expect(result.car).to eq(pod)
        end

        it 'should unify complex equality expressions (II)' do
          expr1 = cons(cons(cons(ref_q)), pod)
          expr2 = cons(cons(cons(pea)), pod)
          goal = equals_goal(expr1, expr2)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:34
          # (run* q (==  '(((,q)) pod) `(((pea)) pod))) ;; => ('pod)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_falsey
          expect(result.car).to eq(pea)
        end

        it 'should unify complex equality expressions (II)' do
          expr1 = cons(cons(cons(ref_q)), pod)
          expr2 = cons(cons(cons(ref_x)), pod)
          goal = equals_goal(expr1, expr2)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:35
          # (run* q (fresh (x) (==  '(((,q)) pod) `(((,x)) pod)))) ;; => (_0)
          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy
          expect(ref_x.fresh?(fresh_env)).to be_truthy
          expect(result.car).to eq(any_value(0))
        end

        it 'should unify complex equality expressions (II)' do
          # # Reasoned S2, frame 1:36
          # # (run* q (fresh (x) (==  '(((,q)) (,x)) `(((,x)) pod)))) ;; => ('pod)
          expr1 = cons(cons(cons(ref_q)), ref_x)
          expr2 = cons(cons(cons(ref_x)), pod)
          goal = equals_goal(expr1, expr2)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          result = instance.run

          # Does propagate work correctly?
          expect(ref_q.fresh?(instance.env)).to be_truthy # x isn't defined here
          expect(ref_q.fresh?(fresh_env)).to be_falsey
          expect(ref_x.fresh?(fresh_env)).to be_falsey
          expect(result.car).to eq(pod)
        end
      end # context
    end # describe
  end # module
end # module
