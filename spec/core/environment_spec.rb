# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/k_symbol'
require_relative '../../lib/mini_kraken/core/variable'
require_relative '../../lib/mini_kraken/core/variable_ref'
require_relative '../../lib/mini_kraken/core/outcome'

# Load the class under test
require_relative '../../lib/mini_kraken/core/environment'

module MiniKraken
  module Core
    describe Environment do
      subject { Environment.new }

      context 'Initialization:' do
        it 'should be initialized with an optional parent' do
          expect { Environment.new }.not_to raise_error
          parent = Environment.new
          expect { Environment.new(parent) }.not_to raise_error
        end

        it "shouldn't have variable by default" do
          expect(subject.vars).to be_empty
        end

        it "shouldn't have associations by default" do
          expect(subject.associations).to be_empty
        end

        it 'shold know its parent (if any)' do
          # Case: no parent
          expect(subject.parent).to be_nil

          # Case: there is a parent
          child = Environment.new(subject)
          expect(child.parent).to eq(subject)
        end
      end # context

      context 'Provided services:' do
        let(:var_a) { Variable.new('a') }
        let(:var_b) { Variable.new('b') }
        let(:var_c) { Variable.new('c') }
        let(:var_c_bis) { Variable.new('c') }
        let(:pea) { KSymbol.new(:pea) }
        let(:pod) { KSymbol.new(:pod) }
        let(:pad) { KSymbol.new(:pad) }

        it 'should accept the addition of a variable' do
          subject.add_var(var_a)
          expect(subject.vars).not_to be_empty
          expect(subject.vars['a']).to eq(var_a)
        end

        it 'should accept the addition of multiple variables' do
          subject.add_var(var_a)
          expect(subject.vars).not_to be_empty
          subject.add_var(var_b)
          expect(subject.vars['a']).to eq(var_a)
          expect(subject.vars['b']).to eq(var_b)
        end

        it 'should accept the addition of an association' do
          subject.add_var(var_a)
          assoc = subject.add_assoc('a', pea)
          expect(subject.associations.size).to eq(1)
          expect(subject.associations['a']).to eq([assoc])
        end

        it 'should tell that a newborn variable is fresh' do
          subject.add_var(var_a)

          # By default, a variable is fresh...
          expect(subject.fresh?(var_a)).to be_truthy
        end

        it "should tell variable associated with a literal value isn't fresh" do
          subject.add_var(var_a)

          # Let's associate an atomic term...
          subject.add_assoc('a', pea)

          expect(subject.fresh?(var_a)).to be_falsey
        end

        it 'should cope with a variable associated with another variable' do
          subject.add_var(var_a)
          subject.add_var(var_b)

          # Let's associate a with (fresh) b
          subject.add_assoc(var_a, var_b)
          expect(subject.fresh?(var_a)).to be_truthy

          # Now associate b with something ground...
          subject.add_assoc(var_b, pea)

          # b is no more fresh, so is ... a
          expect(subject.fresh?(var_b)).to be_falsey
          expect(subject.fresh?(var_a)).to be_falsey
        end

        it 'should remove all associations' do
          subject.add_var(var_a)
          subject.add_assoc(var_a, pea)

          subject.add_var(var_b)
          subject.add_assoc(var_b, pod)

          subject.clear
          expect(subject.fresh?(var_a)).to be_truthy
          expect(subject.fresh?(var_a)).to be_truthy
        end

        it 'should propagate associations up in the environment hierarchy' do
          parent = Environment.new
          parent.add_var(var_a)
          instance = Environment.new(parent)
          instance.add_var(var_b)

          outcome = Outcome.new(:"#s", instance)
          outcome.add_assoc(var_a, pea)
          outcome.add_assoc(var_b, pod)
          expect(outcome.associations.size).to eq(2)

          # Propagate: outcome -> .. -> instance
          instance.propagate(outcome)
          expect(outcome.associations.size).to eq(1)
          expect(instance.associations[var_b.name]).not_to be_nil
          expect(parent.associations[var_a.name]).to be_nil

          # Propagate: outcome -> .. -> parent
          parent.propagate(outcome)
          expect(outcome.associations).to be_empty
          expect(parent.associations[var_b.name]).to be_nil
          expect(parent.associations[var_a.name]).not_to be_nil
        end
      end # context
    end # describe
  end # module
end # module
