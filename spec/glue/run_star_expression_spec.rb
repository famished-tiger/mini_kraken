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
        let(:ref_y) { Core::VariableRef.new('y') }
        let(:ref_s) { Core::VariableRef.new('s') }
        let(:ref_t) { Core::VariableRef.new('t') }
        let(:ref_u) { Core::VariableRef.new('u') }        

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

        it 'should keep variable fresh when no unification occurs (II)' do
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

          #  Reasoned S2, frame 1:40
          expect(ref_q.different_from?(ref_x, fresh_env)).to be_truthy
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

          # q should be fused with x...
          expect(ref_q.fused_with?(ref_x, fresh_env)).to be_truthy
          expect(ref_q.names_fused(fresh_env)).to eq(['x'])
          expect(ref_x.names_fused(fresh_env)).to eq(['q'])
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

        it 'should unify complex equality expressions (III)' do
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

        it 'should unify complex equality expressions (IV)' do
          # Reasoned S2, frame 1:36
          # (run* q (fresh (x) (==  '(((,q)) (,x)) `(((,x)) pod)))) ;; => ('pod)
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

        it 'should unify with repeated fresh variable' do
          # Reasoned S2, frame 1:37
          # (run* q (fresh (x) (==  '( ,x ,x) q))) ;; => (_0 _0)
          expr1 = cons(ref_x, cons(ref_x))
          goal = equals_goal(expr1, ref_q)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          result = instance.run
          expect(ref_q.fresh?(instance.env)).to be_truthy # x isn't defined here
          expect(ref_q.fresh?(fresh_env)).to be_truthy
          expect(ref_x.fresh?(fresh_env)).to be_truthy
          expect(result.car).to eq(cons(any_value(0), cons(any_value(0))))
        end

        it 'should unify multiple times' do
          # Reasoned S2, frame 1:38
          # (run* q (fresh (x) (fresh (y) (==  '( ,q ,y) '((,x ,y) ,x))))) ;; => (_0 _0)
          expr1 = cons(ref_q, cons(ref_y))
          expr2 = cons(cons(ref_x, cons(ref_y)), cons(ref_x))
          goal = equals_goal(expr1, expr2)
          fresh_env_y = FreshEnv.new(['y'], goal)
          fresh_env_x = FreshEnv.new(['x'], fresh_env_y)
          instance = RunStarExpression.new('q', fresh_env_x)

          result = instance.run
          expect(ref_q.fresh?(fresh_env_y)).to be_truthy
          expect(ref_q.bound?(fresh_env_y)).to be_truthy
          expect(ref_x.fresh?(fresh_env_y)).to be_truthy
          expect(ref_x.bound?(fresh_env_y)).to be_truthy
          expect(ref_y.fresh?(fresh_env_y)).to be_truthy
          expect(ref_y.bound?(fresh_env_y)).to be_truthy

          # y should be fused with x...
          expect(ref_y.fused_with?(ref_x, fresh_env_y)).to be_truthy
          expect(ref_x.names_fused(fresh_env_y)).to eq(['y'])
          expect(ref_y.names_fused(fresh_env_y)).to eq(['x'])
          expect(result.car).to eq(cons(any_value(0), cons(any_value(0))))
        end

        it 'should support multiple fresh variables' do
          # Reasoned S2, frame 1:41
          # (run* q (fresh (x) (fresh (y) (==  '( ,x ,y) q)))) ;; => (_0 _1)
          expr1 = cons(ref_x, cons(ref_y))
          goal = equals_goal(expr1, ref_q)
          fresh_env_y = FreshEnv.new(['y'], goal)
          fresh_env_x = FreshEnv.new(['x'], fresh_env_y)
          instance = RunStarExpression.new('q', fresh_env_x)

          result = instance.run
          expect(ref_q.fresh?(fresh_env_y)).to be_truthy
          # q should be bound to '(,x ,y)
          expect(ref_q.bound?(fresh_env_y)).to be_truthy
          expect(ref_x.fresh?(fresh_env_y)).to be_truthy
          expect(ref_x.bound?(fresh_env_y)).to be_falsey
          expect(ref_y.fresh?(fresh_env_y)).to be_truthy
          expect(ref_y.bound?(fresh_env_y)).to be_falsey
          expect(result.car).to eq(cons(any_value(0), cons(any_value(1))))
        end
        
        it 'should work with variable names' do
          # Reasoned S2, frame 1:42
          # (run* s (fresh (t) (fresh (u) (==  '( ,t ,u) s)))) ;; => (_0 _1)
          expr1 = cons(ref_t, cons(ref_u))
          goal = equals_goal(expr1, ref_s)
          fresh_env_u = FreshEnv.new(['u'], goal)
          fresh_env_t = FreshEnv.new(['t'], fresh_env_u)
          instance = RunStarExpression.new('s', fresh_env_t)

          result = instance.run
          expect(ref_s.fresh?(fresh_env_u)).to be_truthy
          # s should be bound to '(,t ,u)
          expect(ref_s.bound?(fresh_env_u)).to be_truthy
          expect(ref_t.fresh?(fresh_env_u)).to be_truthy
          expect(ref_t.bound?(fresh_env_u)).to be_falsey
          expect(ref_u.fresh?(fresh_env_u)).to be_truthy
          expect(ref_u.bound?(fresh_env_u)).to be_falsey
          expect(result.car).to eq(cons(any_value(0), cons(any_value(1))))
        end  

        it 'should support repeated variables' do
          # Reasoned S2, frame 1:43
          # (run* q (fresh (x) (fresh (y) (==  '( ,x ,y ,x) q)))) ;; => (_0 _1 _0)
          expr1 = cons(ref_x, cons(ref_y, cons(ref_x)))
          goal = equals_goal(expr1, ref_q)
          fresh_env_y = FreshEnv.new(['y'], goal)
          fresh_env_x = FreshEnv.new(['x'], fresh_env_y)
          instance = RunStarExpression.new('q', fresh_env_x)

          result = instance.run
          expect(ref_q.fresh?(fresh_env_y)).to be_truthy
          # q should be bound to '(,x ,y, ,x)
          expect(ref_q.bound?(fresh_env_y)).to be_truthy
          expect(ref_x.fresh?(fresh_env_y)).to be_truthy
          expect(ref_y.fresh?(fresh_env_y)).to be_truthy
          expect(result.car).to eq(cons(any_value(0), cons(any_value(1), cons(any_value(0)))))
        end        
      end # context
    end # describe
  end # module
end # module
