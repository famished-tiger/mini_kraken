# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/conde'
require_relative '../../lib/mini_kraken/core/conj2'
require_relative '../../lib/mini_kraken/core/def_relation'
require_relative '../../lib/mini_kraken/core/disj2'
require_relative '../../lib/mini_kraken/core/equals'
require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/formal_arg'
require_relative '../../lib/mini_kraken/core/formal_ref'
require_relative '../../lib/mini_kraken/core/goal_template'
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
      let(:fails) { Core::Goal.new(Core::Fail.instance, []) }
      let(:succeeds) { Core::Goal.new(Core::Succeed.instance, []) }
      subject { RunStarExpression.new('q', sample_goal) }

      context 'Initialization:' do
        it 'could be initialized with a name and a goal' do
          expect { RunStarExpression.new('q', sample_goal) }.not_to raise_error
        end

        it 'could be initialized with multiple names and a goal' do
          expect { RunStarExpression.new(%w[r x y], sample_goal) }.not_to raise_error
        end

        it 'could be initialized with multiple names and goals' do
          expect { RunStarExpression.new(%w[r x y], [succeeds, succeeds]) }.not_to raise_error
        end

        it 'should know its variables' do
          expect(subject.env.vars['q']).not_to be_nil
          expect(subject.env.vars.values[0].name).to eq('q')
        end

        it 'should know its goal' do
          expect(subject.env.goal).to eq(sample_goal)
        end
      end # context

      context 'Provided services:' do
        let(:k_false) { k_boolean(false) }
        let(:k_true) { k_boolean(true) }
        let(:bean) { k_symbol(:bean) }
        let(:corn) { k_symbol(:corn) }
        let(:cup) { k_symbol(:cup) }
        let(:green) { k_symbol(:green) }
        let(:lentil) { k_symbol(:lentil) }
        let(:meal) { k_symbol(:meal) }
        let(:oil) { k_symbol(:oil) }
        let(:olive) { k_symbol(:olive) }
        let(:red) { k_symbol(:red) }
        let(:soup) { k_symbol(:soup) }
        let(:split) { k_symbol(:split) }
        let(:tea) { k_symbol(:tea) }
        let(:virgin) { k_symbol(:virgin) }
        let(:ref_q) { Core::VariableRef.new('q') }
        let(:ref_r) { Core::VariableRef.new('r') }
        let(:ref_x) { Core::VariableRef.new('x') }
        let(:ref_y) { Core::VariableRef.new('y') }
        let(:ref_z) { Core::VariableRef.new('z') }
        let(:ref_s) { Core::VariableRef.new('s') }
        let(:ref_t) { Core::VariableRef.new('t') }
        let(:ref_u) { Core::VariableRef.new('u') }
        let(:ref_z) { Core::VariableRef.new('z') }
        let(:t_ref) { Core::FormalRef.new('t') }
        let(:equals_tea) { Core::GoalTemplate.new(Core::Equals.instance, [tea, t_ref]) }
        let(:equals_cup) { Core::GoalTemplate.new(Core::Equals.instance, [cup, t_ref]) }
        let(:g_template) { Core::GoalTemplate.new(Core::Disj2.instance, [equals_tea, equals_cup]) }
        let(:formal_t) { Core::FormalArg.new('t') }

        # Reasoned S2, frame 1:82
        # (defrel (teacupo t)
        #   (disj2 (== 'tea t) (== 'cup t)))
        let(:teacupo_rel) { Core::DefRelation.new('teacupo', g_template, [formal_t]) }

        it 'should return a null list with the fail goal' do
          # Reasoned S2, frame 1:7
          # (run* q #u) ;; => ()
          failing = Core::Goal.new(Core::Fail.instance, [])
          instance = RunStarExpression.new('q', failing)

          expect(instance.run).to be_null
        end

        it 'should return a null list when a goal fails' do
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
        end

        it 'should unify the righthand variable(s)' do
          goal = equals_goal(pea, ref_q)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:12
          # (run* q (== 'pea q) ;; => (pea)
          expect(instance.run.car).to eq(pea)
        end

        it 'should return a null list with the succeed goal' do
          instance = RunStarExpression.new('q', succeeds)
          expect(instance.env.vars).to be_include('q')

          # (display (run* q succeed)) ;; => (_0)
          # Reasoned S2, frame 1:16
          result = instance.run

          # Reasoned S2, frame 1:17
          expect(result.car).to eq(any_value(0))
        end

        it 'should keep variable fresh when no unification occurs (I)' do
          goal = equals_goal(pea, pea)
          instance = RunStarExpression.new('q', goal)

          # (display (run* q (== 'pea 'pea))) ;; => (_0)
          # Reasoned S2, frame 1:19
          result = instance.run
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
          expect(result.car).to eq(any_value(0))
        end

        it 'should accept the nesting of sub-environment' do
          goal = equals_goal(pea, ref_q)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:21..23
          # (run* q (fresh (x) (== 'pea q))) ;; => (pea)
          result = instance.run

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
          expect(result.car).to eq(any_value(0))
        end

        it 'should accept expression with variables' do
          goal = equals_goal(cons(ref_x), ref_q)
          fresh_env = FreshEnv.new(['x'], goal)
          instance = RunStarExpression.new('q', fresh_env)

          # Reasoned S2, frame 1:25
          # (run* q (fresh (x) (== (cons x '()) q))) ;; => ((_0))
          result = instance.run
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
          expect(result.car).to eq(pod)
        end

        it 'should unify complex equality expressions (II)' do
          expr1 = cons(cons(cons(ref_q)), pod)
          expr2 = cons(cons(cons(pea)), pod)
          goal = equals_goal(expr1, expr2)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:34
          # (run* q (==  '(((,q)) pod) `(((pea)) pod))) ;; => ('pea)
          result = instance.run
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

          # y should be fused with x...
          var_x = fresh_env_y.name2var('x')
          var_y = fresh_env_y.name2var('y')
          expect(var_x.i_name).to eq(var_y.i_name)
          expect(ref_y.fused_with?(ref_x, fresh_env_y)).to be_truthy
          expect(ref_x.names_fused(fresh_env_y)).to eq(['y'])
          expect(ref_y.names_fused(fresh_env_y)).to eq(['x'])

          # q should be bound to '(,x ,x)
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
          # q should be bound to '(,x ,y)
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
          # s should be bound to '(,t ,u)
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
          # q should be bound to '(,x ,y, ,x)
          expect(result.car).to eq(cons(any_value(0), cons(any_value(1), cons(any_value(0)))))
        end

        it 'should support conjunction of two succeed' do
          goal = conj2_goal(succeeds, succeeds)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:50
          # (run* q (conj2 succeed succeed)) ;; => (_0)
          result = instance.run
          expect(result.car).to eq(any_value(0))
        end

        it 'should support conjunction of one succeed and a successful goal' do
          subgoal = equals_goal(corn, ref_q)
          goal = conj2_goal(succeeds, subgoal)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:51
          # (run* q (conj2 succeed (== 'corn q)) ;; => ('corn)
          result = instance.run
          expect(result.car).to eq(corn)
        end

        it 'should support conjunction of one fail and a successful goal' do
          subgoal = equals_goal(corn, ref_q)
          goal = conj2_goal(fails, subgoal)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:52
          # (run* q (conj2 fail (== 'corn q)) ;; => ()
          expect(instance.run).to be_null
        end

        it 'should support conjunction of two contradictory goals' do
          subgoal1 = equals_goal(corn, ref_q)
          subgoal2 = equals_goal(meal, ref_q)
          goal = conj2_goal(subgoal1, subgoal2)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:53
          # (run* q (conj2 (== 'corn q)(== 'meal q)) ;; => ()
          expect(instance.run).to be_null
        end

        it 'should succeed the conjunction of two identical goals' do
          subgoal1 = equals_goal(corn, ref_q)
          subgoal2 = equals_goal(corn, ref_q)
          goal = conj2_goal(subgoal1, subgoal2)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:54
          # (run* q (conj2 (== 'corn q)(== 'corn q)) ;; => ('corn)
          result = instance.run
          expect(result.car).to eq(corn)
        end

        it 'should not yield solution when both disjunction arguments fail' do
          goal = disj2_goal(fails, fails)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:55
          # (run* q (disj2 fail fail)) ;; => ()
          expect(instance.run).to be_null
        end

        it 'should yield solution when first argument succeed' do
          subgoal = Core::Goal.new(Core::Equals.instance, [olive, ref_q])
          goal = disj2_goal(subgoal, fails)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:56
          # (run* q (disj2 (== 'olive q) fail)) ;; => ('olive)
          result = instance.run
          expect(result.car).to eq(olive)
        end

        it 'should yield solution when second argument succeed' do
          subgoal = Core::Goal.new(Core::Equals.instance, [oil, ref_q])
          goal = disj2_goal(fails, subgoal)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:57
          # (run* q (disj2 fail (== 'oil q))) ;; => (oil)
          result = instance.run
          expect(result.car).to eq(oil)
        end

        it 'should yield solutions when both arguments succeed' do
          subgoal1 = Core::Goal.new(Core::Equals.instance, [olive, ref_q])
          subgoal2 = Core::Goal.new(Core::Equals.instance, [oil, ref_q])
          goal = disj2_goal(subgoal1, subgoal2)
          instance = RunStarExpression.new('q', goal)

          # Reasoned S2, frame 1:58
          # (run* q (disj2 (== 'olive q) (== 'oil q))) ;; => (olive oil)
          result = instance.run
          expect(result.car).to eq(olive)
          expect(result.cdr.car).to eq(oil)
        end

        it 'should support the nesting of variables and disjunction' do
          # Reasoned S2, frame 1:59
          # (run* q (fresh (x) (fresh (y) (disj2  (== '( ,x ,y ) q) (== '( ,x ,y ) q)))))
          # ;; => ((_0 _1) (_0 _1))
          expr1 = cons(ref_x, cons(ref_y))
          subgoal1 = equals_goal(expr1, ref_q)
          expr2 = cons(ref_y, cons(ref_x))
          subgoal2 = equals_goal(expr2, ref_q)
          goal = disj2_goal(subgoal1, subgoal2)
          fresh_env_y = FreshEnv.new(['y'], goal)
          fresh_env_x = FreshEnv.new(['x'], fresh_env_y)
          instance = RunStarExpression.new('q', fresh_env_x)

          result = instance.run
          # q should be bound to '(,x ,y), then to '(,y ,x)
          expect(result.car).to eq(cons(any_value(0), cons(any_value(1))))
          expect(result.cdr.car).to eq(cons(any_value(0), cons(any_value(1))))
        end

        it 'should accept nesting of disj2 and conj2 (I)' do
          conj_subgoal = Core::Goal.new(Core::Equals.instance, [olive, ref_x])
          conjunction = conj2_goal(conj_subgoal, fails)
          subgoal = Core::Goal.new(Core::Equals.instance, [oil, ref_x])
          goal = disj2_goal(conjunction, subgoal)
          instance = RunStarExpression.new('x', goal)

          # Reasoned S2, frame 1:62
          # (run* x (disj2
          #           (conj2 (== 'olive x) fail)
          #           (== 'oil x))) ;; => (oil)
          result = instance.run
          expect(result.car).to eq(oil)
        end

        it 'should accept nesting of disj2 and conj2 (II)' do
          conj_subgoal = Core::Goal.new(Core::Equals.instance, [olive, ref_x])
          conjunction = conj2_goal(conj_subgoal, succeeds)
          subgoal = Core::Goal.new(Core::Equals.instance, [oil, ref_x])
          goal = disj2_goal(conjunction, subgoal)
          instance = RunStarExpression.new('x', goal)

          # Reasoned S2, frame 1:63
          # (run* x (disj2
          #           (conj2 (== 'olive x) succeed)
          #           ('oil x))) ;; => (olive oil)
          result = instance.run
          expect(result.car).to eq(olive)
          expect(result.cdr.car).to eq(oil)
        end

        it 'should accept nesting of disj2 and conj2 (III)' do
          conj_subgoal = Core::Goal.new(Core::Equals.instance, [olive, ref_x])
          conjunction = conj2_goal(conj_subgoal, succeeds)
          subgoal = Core::Goal.new(Core::Equals.instance, [oil, ref_x])
          goal = disj2_goal(subgoal, conjunction)
          instance = RunStarExpression.new('x', goal)

          # Reasoned S2, frame 1:64
          # (run* x (disj2
          #           (== 'oil x)
          #           (conj2 (== 'olive x) succeed))) ;; => (oil olive)
          result = instance.run
          expect(result.car).to eq(oil)
          expect(result.cdr.car).to eq(olive)
        end

        it 'should accept nesting of disj2 and conj2 (IV)' do
          oil_goal = Core::Goal.new(Core::Equals.instance, [oil, ref_x])
          disja = disj2_goal(succeeds, oil_goal)
          olive_goal = Core::Goal.new(Core::Equals.instance, [olive, ref_x])
          disjb = disj2_goal(olive_goal, disja)
          virgin_goal = Core::Goal.new(Core::Equals.instance, [virgin, ref_x])
          conjunction = conj2_goal(virgin_goal, fails)
          goal = disj2_goal(conjunction, disjb)
          instance = RunStarExpression.new('x', goal)

          # Reasoned S2, frame 1:65
          # (run* x (disj2
          #           (conj2(== 'virgin x) fail)
          #           (disj2
          #             (== 'olive x)
          #             (dis2
          #               succeed
          #               (== 'oil x))))) ;; => (olive _0 oil)
          result = instance.run
          expect(result.car).to eq(olive)
          expect(result.cdr.car).to eq(any_value(0))
          expect(result.cdr.cdr.car).to eq(oil)
        end

        it 'should accept nesting fresh, disj2 and conj2 expressions (I)' do
          subgoal1 = equals_goal(split, ref_x)
          expr1 = equals_goal(pea, ref_y)
          expr2 = equals_goal(cons(ref_x, cons(ref_y)), ref_r)
          subgoal2 = conj2_goal(expr1, expr2)
          goal = conj2_goal(subgoal1, subgoal2)
          fresh_env_y = FreshEnv.new(['y'], goal)
          fresh_env_x = FreshEnv.new(['x'], fresh_env_y)
          instance = RunStarExpression.new('r', fresh_env_x)

          # Reasoned S2, frame 1:67
          # (run* r
          #   (fresh x
          #     (fresh y
          #       (conj2
          #           (== 'split x)
          #           (conj2
          #             (== 'pea y)
          #             (== '(,x ,y) r)))))) ;; => ((split pea))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
        end

        it 'should accept nesting fresh, disj2 and conj2 expressions (II)' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          subgoal2 = equals_goal(cons(ref_x, cons(ref_y)), ref_r)
          goal = conj2_goal(subgoal1, subgoal2)
          fresh_env_y = FreshEnv.new(['y'], goal)
          fresh_env_x = FreshEnv.new(['x'], fresh_env_y)
          instance = RunStarExpression.new('r', fresh_env_x)

          # Reasoned S2, frame 1:68
          # (run* r
          #   (fresh x
          #     (fresh y
          #       (conj2
          #         (conj2
          #           (== 'split x)
          #           (== 'pea y)
          #         (== '(,x ,y) r)))))) ;; => ((split pea))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
        end

        it 'should accept fresh with multiple variables' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          subgoal2 = equals_goal(cons(ref_x, cons(ref_y)), ref_r)
          goal = conj2_goal(subgoal1, subgoal2)
          fresh_env = FreshEnv.new(%w[x y], goal)
          instance = RunStarExpression.new('r', fresh_env)

          # Reasoned S2, frame 1:70
          # (run* r
          #   (fresh (x y)
          #     (conj2
          #       (conj2
          #         (== 'split x)
          #         (== 'pea y)
          #       (== '(,x ,y) r))))) ;; => ((split pea))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
        end

        it 'should accept multiple variables' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          subgoal2 = equals_goal(cons(ref_x, cons(ref_y)), ref_r)
          goal = conj2_goal(subgoal1, subgoal2)
          instance = RunStarExpression.new(%w[r x y], goal)

          # Reasoned S2, frame 1:72
          # (run* (r x y)
          #   (conj2
          #     (conj2
          #       (== 'split x)
          #       (== 'pea y))
          #     (== '(,x ,y) r))) ;; => (((split pea) split pea))
          #             o
          #            / \
          #            o  nil
          #          /  \
          #         /    \
          #        /      \
          #       /        \
          #      /          \
          #      o           o
          #     / \         / \
          # split  o   split   o
          #       / \         / \
          #    pea  nil     pea  nil
          result = instance.run
          expect(result.car.car.car).to eq(split)
          expect(result.car.car.cdr.car).to eq(pea)
          expect(result.car.car.cdr.cdr).to be_nil
          expect(result.car.cdr.car).to eq(split)
          expect(result.car.cdr.cdr.car).to eq(pea)
          expect(result.car.cdr.cdr.cdr).to be_nil
        end

        it 'should allow simplification of expressions' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          goal = conj2_goal(expr1, expr2)
          instance = RunStarExpression.new(%w[x y], goal)

          # Reasoned S2, frame 1:75
          # (run* (x y)
          #   (conj2
          #     (== 'split x)
          #     (== 'pea y))) ;; => ((split pea))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
        end

        it 'should allow simplication of expressions' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          expr3 = equals_goal(red, ref_x)
          expr4 = equals_goal(bean, ref_y)
          subgoal2 = conj2_goal(expr3, expr4)
          goal = disj2_goal(subgoal1, subgoal2)
          instance = RunStarExpression.new(%w[x y], goal)

          # Reasoned S2, frame 1:76
          # (run* (x y)
          #   (disj2
          #     (conj2 (== 'split x) (== 'pea y))
          #     (conj2 (== 'red x) (== 'bean y)))) ;; => ((split pea)(red bean))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
          expect(result.cdr.car.car).to eq(red)
          expect(result.cdr.car.cdr.car).to eq(bean)
        end

        it 'should allow nesting a disjunction inside of conjunction' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(red, ref_x)
          subgoal1 = disj2_goal(expr1, expr2)
          subgoal2 = equals_goal(ref_x, ref_y)
          goal = conj2_goal(subgoal1, subgoal2)
          instance = RunStarExpression.new(%w[x y], goal)

          # (display (run* (x y)
          #   (conj2
          #     (disj2
          #       (== 'split x)
          #       (== 'red x))
          #     (== x y)))) ;; => ((split split) (red red))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(split)
          expect(result.cdr.car.cdr.car).to eq(red)
        end

        it 'should accept fresh with multiple variables' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          expr3 = equals_goal(red, ref_x)
          expr4 = equals_goal(bean, ref_y)
          subgoal2 = conj2_goal(expr3, expr4)
          subgoal3 = disj2_goal(subgoal1, subgoal2)
          subgoal4 = equals_goal(cons(ref_x, cons(ref_y, cons(soup))), ref_r)
          goal = conj2_goal(subgoal3, subgoal4)
          fresh_env = FreshEnv.new(%w[x y], goal)
          instance = RunStarExpression.new('r', fresh_env)

          # Reasoned S2, frame 1:77
          # (run* r
          #   (fresh (x y)
          #     (conj2
          #       (disj2
          #         (conj2 (== 'split x) (== 'pea y))
          #         (conj2 (== 'red x) (== 'bean y)))
          #       (== '(,x ,y soup) r)))) ;; => ((split pea soup) (red bean soup))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
          expect(result.car.cdr.cdr.car).to eq(soup)
          expect(result.cdr.car.car).to eq(red)
          expect(result.cdr.car.cdr.car).to eq(bean)
          expect(result.cdr.car.cdr.cdr.car).to eq(soup)
        end

        it 'should allow fresh with multiple goals' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          expr3 = equals_goal(red, ref_x)
          expr4 = equals_goal(bean, ref_y)
          subgoal2 = conj2_goal(expr3, expr4)
          goal1 = disj2_goal(subgoal1, subgoal2)
          goal2 = equals_goal(cons(ref_x, cons(ref_y, cons(soup))), ref_r)
          fresh_env = FreshEnv.new(%w[x y], [goal1, goal2])
          instance = RunStarExpression.new('r', fresh_env)

          # Reasoned S2, frame 1:78
          # (run* r
          #   (fresh (x y)
          #     (disj2
          #       (conj2 (== 'split x) (== 'pea y))
          #       (conj2 (== 'red x) (== 'bean y)))
          #     (== '(,x ,y soup) r))) ;; => ((split pea soup) (red bean soup))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
          expect(result.car.cdr.cdr.car).to eq(soup)
          expect(result.cdr.car.car).to eq(red)
          expect(result.cdr.car.cdr.car).to eq(bean)
          expect(result.cdr.car.cdr.cdr.car).to eq(soup)
        end

        it 'should allow run* with multiple goals' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          subgoal1 = conj2_goal(expr1, expr2)
          expr3 = equals_goal(red, ref_x)
          expr4 = equals_goal(bean, ref_y)
          subgoal2 = conj2_goal(expr3, expr4)
          goal1 = disj2_goal(subgoal1, subgoal2)
          goal2 = equals_goal(soup, ref_z)
          instance = RunStarExpression.new(%w[x y z], [goal1, goal2])

          # Reasoned S2, frame 1:80
          # (run* (x y z)
          #   (disj2
          #     (conj2 (== 'split x) (== 'pea y))
          #     (conj2 (== 'red x) (== 'bean y)))
          #   (== 'soup z)) ;; => ((split pea soup) (red bean soup))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
          expect(result.car.cdr.cdr.car).to eq(soup)
          expect(result.cdr.car.car).to eq(red)
          expect(result.cdr.car.cdr.car).to eq(bean)
          expect(result.cdr.car.cdr.cdr.car).to eq(soup)
        end

        it 'should allow simplified expressions with multiple goals' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          instance = RunStarExpression.new(%w[x y], [expr1, expr2])

          # Reasoned S2, frame 1:81
          # (run* (x y)
          #   (== 'split x)
          #   (== 'pea y)) ;; => ((split pea))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
        end

        it 'should solve expression with defrel' do
          teacupo_goal = Core::Goal.new(teacupo_rel, [ref_x])

          # Reasoned S2, frame 1:83
          # (run* x
          #   (teacupo x)) ;; => ((tea cup))
          instance = RunStarExpression.new('x', teacupo_goal)

          result = instance.run
          expect(result.car).to eq(tea)
          expect(result.cdr.car).to eq(cup)
        end

        it 'should solve expression with defrel and booleans' do
          teacupo_goal = Core::Goal.new(teacupo_rel, [ref_x])
          expr2 = equals_goal(k_true, ref_y)
          subgoal1 = conj2_goal(teacupo_goal, expr2)
          expr3 = equals_goal(k_false, ref_x)
          expr4 = equals_goal(k_true, ref_y)
          subgoal2 = conj2_goal(expr3, expr4)
          goal = disj2_goal(subgoal1, subgoal2)
          # Reasoned S2, frame 1:84
          # (run* (x y)
          #   (disj2
          #     (conj2 (teacupo x) (== #t y))
          #     (conj2 (== #f x) (== #t y))) ;; => ((#f #t)(tea #t) (cup #t))
          instance = RunStarExpression.new(%w[x y], goal)

          result = instance.run
          # Order of solutions differs from RS book
          expect(result.car).to eq(cons(tea, cons(true)))
          expect(result.cdr.car).to eq(cons(cup, cons(true)))
          expect(result.cdr.cdr.car).to eq(cons(false, cons(true)))
        end

        it 'should solve expression with two variable and defrel' do
          teacupo_goal1 = Core::Goal.new(teacupo_rel, [ref_x])
          teacupo_goal2 = Core::Goal.new(teacupo_rel, [ref_y])

          # Reasoned S2, frame 1:85
          # (run* (x y)
          #   (teacupo x)
          #   (teacupo y)) ;; => ((tea tea)(tea cup)(cup tea)(cup c))
          instance = RunStarExpression.new(%w[x y], [teacupo_goal1, teacupo_goal2])

          result = instance.run
          expect(result.car).to eq(cons(tea, cons(tea)))
          expect(result.cdr.car).to eq(cons(tea, cons(cup)))
          expect(result.cdr.cdr.car).to eq(cons(cup, cons(tea)))
          expect(result.cdr.cdr.cdr.car).to eq(cons(cup, cons(cup)))
        end

        it 'should solve expression with two variable and defrel' do
          teacupo_goal1 = Core::Goal.new(teacupo_rel, [ref_x])
          teacupo_goal2 = Core::Goal.new(teacupo_rel, [ref_x])

          # Reasoned S2, frame 1:86
          # (run* (x y)
          #   (teacupo x)
          #   (teacupo x)) ;; => ((tea _0)(cup _0))
          instance = RunStarExpression.new(%w[x y], [teacupo_goal1, teacupo_goal2])

          result = instance.run
          expect(result.car).to eq(cons(tea, cons(any_value(0))))
          expect(result.cdr.car).to eq(cons(cup, cons(any_value(0))))
        end

        it 'should solve expression with defrel and booleans' do
          teacupo_goal1 = Core::Goal.new(teacupo_rel, [ref_x])
          teacupo_goal2 = Core::Goal.new(teacupo_rel, [ref_x])
          subgoal1 = conj2_goal(teacupo_goal1, teacupo_goal2)
          expr3 = equals_goal(k_false, ref_x)
          expr4 = Core::Goal.new(teacupo_rel, [ref_y])
          subgoal2 = conj2_goal(expr3, expr4)
          goal = disj2_goal(subgoal1, subgoal2)
          # Reasoned S2, frame 1:87
          # (run* (x y)
          #   (disj2
          #     (conj2 (teacupo x) (teacupo x))
          #     (conj2 (== #f x) (teacupo y)))) ;; => ((#f tea)(#f cup)(tea _0)(cup _0))
          instance = RunStarExpression.new(%w[x y], goal)

          result = instance.run
          # Order of solutions differs from RS book
          expect(result.car).to eq(cons(tea, cons(any_value(0))))
          expect(result.cdr.car).to eq(cons(cup, cons(any_value(0))))
          expect(result.cdr.cdr.car).to eq(cons(false, cons(tea)))
          expect(result.cdr.cdr.cdr.car).to eq(cons(false, cons(cup)))
        end

        it 'should allow conde in the goal expression' do
          teacupo_goal1 = Core::Goal.new(teacupo_rel, [ref_x])
          teacupo_goal2 = Core::Goal.new(teacupo_rel, [ref_x])
          expr3 = equals_goal(k_false, ref_x)
          expr4 = Core::Goal.new(teacupo_rel, [ref_y])
          goal = conde_goal([[teacupo_goal1, teacupo_goal2], [expr3, expr4]])
          # Reasoned S2, frame 1:88
          # (run* (x y)
          #   (conde
          #     ((teacupo x) (teacupo x))
          #     ((== #f x) (teacupo y)))) ;; => ((#f tea)(#f cup)(tea _0)(cup _0))
          instance = RunStarExpression.new(%w[x y], goal)

          result = instance.run
          expect(result.car).to eq(cons(tea, cons(any_value(0))))
          expect(result.cdr.car).to eq(cons(cup, cons(any_value(0))))
          expect(result.cdr.cdr.car).to eq(cons(false, cons(tea)))
          expect(result.cdr.cdr.cdr.car).to eq(cons(false, cons(cup)))
        end

        it 'should allow simplication of expressions (conde version)' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          combo1 = [expr1, expr2]
          expr3 = equals_goal(red, ref_x)
          expr4 = equals_goal(bean, ref_y)
          combo2 = [expr3, expr4]
          goal = conde_goal([combo1, combo2])
          instance = RunStarExpression.new(%w[x y], goal)

          # Reasoned S2, frame 1:88 (second part, a rewrite of 1:76)
          # (run* (x y)
          #   (conde
          #     ((== 'split x) (== 'pea y))
          #     ((== 'red x) (== 'bean y)))) ;; => ((split pea)(red bean))
          result = instance.run
          expect(result.car.car).to eq(split)
          expect(result.car.cdr.car).to eq(pea)
          expect(result.cdr.car.car).to eq(red)
          expect(result.cdr.car.cdr.car).to eq(bean)
        end

        it 'should accept nesting of disj2 and conj2 (conde version)' do
          equals_olive = Core::Goal.new(Core::Equals.instance, [olive, ref_x])
          combo = [equals_olive, fails]
          equals_oil = Core::Goal.new(Core::Equals.instance, [oil, ref_x])
          goal = conde_goal([combo, equals_oil])
          instance = RunStarExpression.new('x', goal)

          # Reasoned S2, frame 1:89 (rewrite of 1:62)
          # (run* x
          #   (conde
          #     ((== 'olive x) fail)
          #     ('oil x))) ;; => (oil)
          result = instance.run
          expect(result.car).to eq(oil)
        end

        it 'should accept nesting of conde inside a fresh context' do
          equals_lentil = Core::Goal.new(Core::Equals.instance, [lentil, ref_z])
          fresh_env = FreshEnv.new(['z'], equals_lentil)
          equals_xy = Core::Goal.new(Core::Equals.instance, [ref_x, ref_y])
          goal = conde_goal([fresh_env, equals_xy])
          instance = RunStarExpression.new(%w[x y], goal)
          fresh_env.parent = instance.env

          # Reasoned S2, frame 1:90
          # (run* (x y)
          #   (conde
          #     ((fresh (z)
          #       (== 'lentil z)))
          #     ((== x y)))) ;; => ((_0 _1)(_0 _0))
          result = instance.run
          expect(result.car).to eq(cons(any_value(0), cons(any_value(1))))
          expect(result.cdr.car).to eq(cons(any_value(0), cons(any_value(0))))
        end

        it 'accepts conde with more than two condition lines' do
          expr1 = equals_goal(split, ref_x)
          expr2 = equals_goal(pea, ref_y)
          combo1 = [expr1, expr2]
          expr3 = equals_goal(red, ref_x)
          expr4 = equals_goal(bean, ref_y)
          combo2 = [expr3, expr4]
          expr5 = equals_goal(green, ref_x)
          expr6 = equals_goal(lentil, ref_y)
          combo3 = [expr5, expr6]
          goal = conde_goal([combo1, combo2, combo3])
          instance = RunStarExpression.new(%w[x y], goal)

          # Reasoned S2, frame 1:91
          # (run* (x y)
          #   (conde
          #     ((== 'split x) (== 'pea y))
          #     ((== 'red x) (== 'bean y))
          #     ((== 'green x) (== 'lentil y))))
          # ;; => ((split pea)(red bean)(green lentil))
          result = instance.run
          expect(result.car).to eq(cons(split, cons(pea)))
          expect(result.cdr.car).to eq(cons(red, cons(bean)))
          expect(result.cdr.cdr.car).to eq(cons(green, cons(lentil)))
        end
      end # context
    end # describe
  end # module
end # module
