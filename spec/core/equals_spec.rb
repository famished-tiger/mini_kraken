# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/environment'

require_relative '../support/factory_methods'
# Load the class under test
require_relative '../../lib/mini_kraken/core/equals'

module MiniKraken
  module Core
    describe Equals do
      include FactoryMethods

      subject { Equals.instance }

      context 'Initialization:' do
        it 'should be created without argument' do
          expect { Equals.instance }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('equals')
        end
      end # context

      context 'Provided services:' do
        def build_var(aName)
          new_var = Variable.new(aName)
          env.add_var(new_var)
          new_var
        end

        def build_var_ref(aName)
          VariableRef.new(aName)
        end

        def solve_for(arg1, arg2)
          solver = subject.solver_for([arg1, arg2], env)
          outcome = solver.resume
          env.propagate(outcome)
          outcome
        end

        let(:pea) { KSymbol.new(:pea) }
        let(:pod) { KSymbol.new(:pod) }
        let(:sample_cons) { ConsCell.new(pea, nil) }
        let(:a_composite) { ConsCell.new(pod) }
        let(:env) { Environment.new }
        let(:var_q) { build_var('q') }
        let(:ref_q) do
          dummy = var_q # Force dependency
          build_var_ref('q')
        end
        let(:ref_q_bis) do
          dummy = var_q # Force dependency
          build_var_ref('q')
        end
        let(:var_x) { build_var('x') }
        let(:ref_x) do
          dummy = var_x  # Force dependency
          build_var_ref('x')
        end
        let(:var_y) { build_var('y') }
        let(:ref_y) do
          dummy = var_y  # Force dependency
          build_var_ref('y')
        end


        it 'should succeed for equal literal arguments' do
          result = solve_for(pea, pea)

          expect(result).to be_kind_of(Outcome)
          expect(result.resultant).to eq(:"#s")
          expect(result.associations).to be_empty
          expect(var_q.fresh?(env)).to be_truthy
        end

        it 'should fail for inequal literal arguments' do
          result = solve_for(pea, pod)

          expect(result.resultant).to eq(:"#u")
          expect(result.associations).to be_empty
          expect(var_q.fresh?(env)).to be_truthy
        end

        it 'should fail for one left literal and one composite arguments' do
          result = solve_for(pea, sample_cons)

          expect(result.resultant).to eq(:"#u")
          expect(result.associations).to be_empty
          expect(var_q.fresh?(env)).to be_truthy
        end

        it 'should fail for one right literal and one composite arguments' do
          result = solve_for(sample_cons, pea)

          expect(result.resultant).to eq(:"#u")
          expect(result.associations).to be_empty
          expect(var_q.fresh?(env)).to be_truthy
        end

        it 'should succeed for a right-handed fresh argument' do
          result = solve_for(pea, ref_q)

          expect(result).to be_successful
          expect(env.associations.size).to eq(1)
          expect(env.associations['q'].first.value).to eq(pea)
          expect(var_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(pea)
        end

        it 'should succeed for a left-handed fresh argument' do
          result = solve_for(ref_q, pea)

          expect(result).to be_successful
          expect(env.associations.size).to eq(1)
          expect(env.associations['q'].first.value).to eq(pea)
          expect(var_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(pea)
        end

        it 'should succeed for a right-handed bound argument equal constant' do
          ref_q.associate(pod, env)

          result = solve_for(pod, ref_q)
          expect(result).to be_successful
          expect(env.associations.size).to eq(1) # No new association
          expect(ref_q.fresh?(result)).not_to be_truthy
          expect(ref_q.values(result).first).to eq(pod)
        end

        it 'should succeed for a left-handed bound argument equal constant' do
          ref_q.associate(pod, env)

          result = solve_for(ref_q, pod)
          expect(result).to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(pod)
        end

        it 'should fail for a right-handed bound argument to a distinct literal' do
          ref_q.associate(pod, env)

          result = solve_for(pea, ref_q)
          expect(result).not_to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(pod)
        end

        it 'should fail for a left-handed bound argument to a distinct literal' do
          ref_q.associate(pod, env)

          result = solve_for(ref_q, pea)
          expect(result).not_to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(pod)
        end

        it 'should succeed for a composite and right-handed fresh argument' do
          result = solve_for(sample_cons, ref_q)

          expect(result).to be_successful
          expect(env.associations.size).to eq(1)
          expect(ref_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(sample_cons)
        end

        it 'should succeed for composite and left-handed fresh argument' do
          result = solve_for(ref_q, sample_cons)

          expect(result).to be_successful
          expect(env.associations.size).to eq(1)
          expect(ref_q.fresh?(result)).to be_falsey
          expect(ref_q.values(result).first).to eq(sample_cons)
        end

        it 'should succeed for a right-handed bound equal argument' do
          ref_q.associate(sample_cons, env)
          composite = ConsCell.new(pea)
          result = solve_for(composite, ref_q)

          expect(result).to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).not_to be_truthy
          expect(ref_q.values(result).first).to eq(sample_cons)
        end

        it 'should succeed for a left-handed bound equal argument' do
          ref_q.associate(sample_cons, env)
          composite = ConsCell.new(pea)
          result = solve_for(ref_q, composite)

          expect(result).to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).not_to be_truthy
          expect(ref_q.values(result).first).to eq(sample_cons)
        end

        it 'should succeed for a right-handed bound unequal argument' do
          ref_q.associate(sample_cons, env)
          composite = ConsCell.new(pod)
          result = solve_for(composite, ref_q)

          expect(result).not_to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).not_to be_truthy
          expect(ref_q.values(result).first).to eq(sample_cons)
        end

        it 'should succeed for a left-handed bound unequal argument' do
          ref_q.associate(sample_cons, env)
          composite = ConsCell.new(pod)
          result = solve_for(ref_q, composite)

          expect(result).not_to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).not_to be_truthy
          expect(ref_q.values(result).first).to eq(sample_cons)
        end

        it 'should succeed for both identical fresh arguments' do
          result = solve_for(ref_q, ref_q)

          expect(result).to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).to be_truthy
        end

        it 'should succeed for both same fresh arguments' do
          result = solve_for(ref_q, ref_q_bis)

          expect(result).to be_successful
          expect(result.associations).to be_empty
          expect(ref_q.fresh?(result)).to be_truthy
          expect(ref_q_bis.fresh?(result)).to be_truthy
        end

        it 'should succeed for both distinct fresh arguments' do
          result = solve_for(ref_x, ref_y)

          expect(result).to be_successful
          expect(env.associations.size).to eq(2) # Symmetric association
          expect(ref_x.fresh?(result)).to be_truthy
          expect(ref_y.fresh?(result)).to be_truthy
        end

        it 'should succeed for arguments bound to equal values' do
          ref_x.associate(pea, env)
          ref_y.associate(pea, env)
          expect(ref_x.fresh?(env)).to be_falsey
          expect(ref_y.fresh?(env)).to be_falsey

          result = solve_for(ref_x, ref_y)
          expect(result).to be_successful
          expect(result.associations).to be_empty
        end

        it 'should fail for arguments bound unequal values' do
          ref_x.associate(pea, env)
          ref_y.associate(pod, env)
          expect(ref_x.fresh?(env)).to be_falsey
          expect(ref_y.fresh?(env)).to be_falsey

          result = solve_for(ref_x, ref_y)
          expect(result).not_to be_successful
          expect(result.associations).to be_empty
        end

        it 'should unify composite terms with variables' do
          # Reasoned S2, frame 1:36
          # (run* q (fresh (x) (==  '(((,q)) (,x)) `(((,x)) pod)))) ;; => ('pod)
          expr1 = cons(cons(ref_q), ref_x)
          expr2 = cons(cons(ref_x), pod)

          result = solve_for(expr1, expr2)
          # require 'debug'
          expect(result).to be_successful
          expect(ref_x.fresh?(env)).to be_falsey
          expect(ref_q.fresh?(env)).to be_falsey
        end
      end # context
    end # describe
  end # module
end # module
