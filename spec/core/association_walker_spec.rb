# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/environment'
require_relative '../support/factory_atomic'
require_relative '../support/factory_methods'

# Load the class under test
require_relative '../../lib/mini_kraken/core/association_walker'


module MiniKraken
  module Core
    describe AssociationWalker do
      include MiniKraken::FactoryAtomic # Use mix-in module
      include FactoryMethods

      subject { AssociationWalker.new }

      context 'Initialization:' do
        it 'should be initialized without argument' do
          expect { AssociationWalker.new }.not_to raise_error
        end

        it "shouldn't have any visitee at initialization" do
          expect(subject.visitees.size).to eq(0)
        end
      end # context

      context 'Provided services:' do
        let(:pea) { k_symbol(:pea) }
        let(:pod) { k_symbol(:pod) }
        let(:var_q) { LogVar.new('q') }
        let(:ref_q) { LogVarRef.new('q') }
        let(:var_x) { LogVar.new('x') }
        let(:ref_x) { LogVarRef.new('x') }
        let(:env) { Environment.new }

        it 'should return composite when it has only atomic term(s)' do
          expr1 = cons(pea)
          expect(subject.walk_value(expr1, env)).to eq(expr1)

          expr2 = cons(pea, pod)
          expect(subject.walk_value(expr2, env)).to eq(expr2)
        end

        it 'should return composite when it has ground composite term(s)' do
          expr1 = cons(pea, cons(pod))
          expect(subject.walk_value(expr1, env)).to eq(expr1)

          expr2 = cons(pea, cons(pod, cons(pea, cons(pod))))
          expect(subject.walk_value(expr2, env)).to eq(expr2)
        end

        it 'should return nil when there is one fresh variable' do
          env.add_var(var_q)
          expr1 = cons(pea, cons(pod, ref_q))
          expect(subject.walk_value(expr1, env)).to be_nil
        end

        it 'should return composite when it has ground composite term(s)' do
          env.add_var(var_q)
          env.add_assoc('q', pea)
          expr1 = cons(pea, cons(pod, cons(ref_q)))
          expect(subject.walk_value(expr1, env)).to eq(expr1)
        end

        it 'should return nil when no assocation exists' do
          env.add_var(var_q)
          env.add_assoc('q', pea)
          env.add_var(var_x)

          expect(subject.find_ground(var_x.name, env)).to be_nil
        end

        it 'should find an atomic term directly associated' do
          env.add_var(var_q)
          env.add_assoc('q', pea)

          result = subject.find_ground(var_q.name, env)
          expect(result).to eq(pea)
        end

        it 'should find an atomic term directly associated' do
          env.add_var(var_q)
          env.add_var(var_x)
          env.add_assoc('q', ref_x)
          env.add_assoc('x', pea)
          expect(env['x']).not_to be_nil

          result = subject.find_ground(var_q.name, env)
          expect(result).to eq(pea)
        end

        it 'should cope with cyclic structures' do
          env.add_var(var_q)
          env.add_var(var_x)
          env.add_assoc('q', ref_x)
          env.add_assoc('x', pea)
          env.add_assoc('x', ref_q)

          result = subject.find_ground(var_q.name, env)
          expect(result).to eq(pea)

          result = subject.find_ground(var_x.name, env)
          expect(result).to eq(pea)
        end

        it 'should cope with a composite with atomic terms only' do
          env.add_var(var_q)
          expr = cons(pea, cons(pod, cons(pea)))
          env.add_assoc('q', expr)

          result = subject.find_ground(var_q.name, env)
          expect(result).to eq(expr)
        end

        it 'should cope with a composite with one fresh variable' do
          env.add_var(var_q)
          env.add_var(var_x)
          expr = cons(pea, cons(pod, cons(ref_x)))
          env.add_assoc('q', expr)

          result = subject.find_ground(var_q.name, env)
          expect(result).to be_nil
        end

        it 'should cope with a composite with one ground variable' do
          env.add_var(var_q)
          env.add_var(var_x)
          expr = cons(pea, cons(pod, cons(ref_x)))
          env.add_assoc('q', expr)
          env.add_assoc('x', pod)

          result = subject.find_ground(var_q.name, env)
          expect(result).to eq(expr)
        end

        it 'should categorize a variable without association as free' do
          env.add_var(var_q)
          result = subject.determine_freshness(ref_q, env)
          expect(result).to be_fresh
          expect(result.associated).to be_nil
        end

        it 'should categorize a variable related to fresh variable as bound' do
          env.add_var(var_q)
          env.add_var(var_x)
          env.add_assoc('q', ref_x)

          result = subject.determine_freshness(ref_q, env)
          expect(result).to be_bound
          expect(result.associated).to eq(ref_x)
        end

        it 'should categorize a variable even in presence of fused var(s)' do
          env.add_var(var_q)
          env.add_var(var_x)
          env.add_assoc('q', ref_x)
          env.add_assoc('x', ref_q)
          # q and x are fused...

          result = subject.determine_freshness(ref_q, env)
          expect(result).to be_fresh
          expect(var_q.i_name).to eq(var_x.i_name)
          expect(env.associations).to be_empty
        end

        it 'should categorize an atomic term as ground term' do
          result = subject.determine_freshness(pea, env)
          expect(result).to be_ground
          expect(result.associated).to eq(pea)
        end

        it 'should categorize a composite term as ground term' do
          # Ground composite: a composite where all members are ground
          composite = cons(pea, cons(pod))
          result = subject.determine_freshness(composite, env)
          expect(result).to be_ground
          expect(result.associated).to eq(composite)
        end

        it 'should categorize a composite term as bound term' do
          # Bound composite: a composite where at least one member is fresh
          env.add_var(var_q)
          composite = cons(pea, cons(ref_q))
          result = subject.determine_freshness(composite, env)
          expect(result).to be_bound
          expect(result.associated).to eq(composite)
        end
      end # context
    end # describe
  end # module
end # module
