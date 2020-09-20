# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../support/factory_atomic'
require_relative '../../lib/mini_kraken/core/log_var'
require_relative '../../lib/mini_kraken/core/log_var_ref'
require_relative '../support/factory_methods'

# Load the class under test
# frozen_string_literal: true

require_relative '../../lib/mini_kraken/core/vocabulary'

module MiniKraken
  module Core
    class TestVocabulary
      include Vocabulary

      def initialize(aParent = nil)
        init_vocabulary(aParent)
      end
    end # class

    # Helper module that simulates an environment-like object.
    module LogVarBearer
      attr_reader :vars
      attr_accessor :ivars

      def init_var_bearer
        @vars = {}
        @ivars = {}
        self
      end

      def add_var(aVarName)
        vars[aVarName] = LogVar.new(aVarName)
        ivars[aVarName] = Set.new([aVarName])
      end
    end # module

    describe Vocabulary do
      include MiniKraken::FactoryAtomic # Use mix-in module
      include FactoryMethods

      let(:parent) { TestVocabulary.new }
      subject { TestVocabulary.new }

      context 'Initialization:' do
        it 'could be initialized without a parent' do
          expect { TestVocabulary.new }.not_to raise_error
        end

        it 'could be initialized with a parent' do
          expect { TestVocabulary.new(parent) }.not_to raise_error
        end

        it 'should know its parent (if any)' do
          expect(subject.parent).to be_nil
          instance = TestVocabulary.new(parent)
          expect(instance.parent).to eq(parent)
        end

        it 'should have no associations at initialization' do
          expect(subject.associations).to be_empty
        end
      end # context

      context 'Provided services:' do
        let(:pea) { k_symbol(:pea) }
        let(:pod) { k_symbol(:pod) }
        let(:ref_q) { LogVarRef.new('q') }
        let(:ref_x) { LogVarRef.new('x') }
        let(:grandma) do
          voc = TestVocabulary.new
          voc.extend(LogVarBearer)
          voc.init_var_bearer
        end
        let(:mother) { TestVocabulary.new(grandma) }
        subject { TestVocabulary.new(mother) }

        it 'should provide a walker over ancestors' do
          walker = subject.ancestor_walker
          expect(walker).to be_kind_of(Enumerator)
          expect(walker.next).to eq(subject)
          expect(walker.next).to eq(mother)
          expect(walker.next).to eq(grandma)
          expect(walker.next).to be_nil
        end

        it 'should know if a variable is defined' do
          expect(subject.include?('q')).to be_falsey
          grandma.add_var('x')
          expect(subject.include?('q')).to be_falsey
          expect(grandma.include?('x')).to be_truthy
          expect(mother.include?('x')).to be_truthy
          expect(subject.include?('x')).to be_truthy
          subject.extend(LogVarBearer)
          subject.init_var_bearer
          subject.add_var('y')
          expect(subject.include?('y')).to be_truthy
          expect(mother.include?('y')).to be_falsey
        end

        it 'should allow the addition of associations' do
          grandma.add_var('q')
          expect(subject['q']).to be_empty
          res_add = mother.add_assoc('q', pea)
          expect(res_add).to be_kind_of(Association)
          expect(subject['q'].size).to eq(1)
          expect(subject['q'].first.value).to eq(pea)

          subject.add_assoc('q', ref_x)
          expect(subject['q'].size).to eq(2)
          expect(subject['q'].first.value).to eq(ref_x)
          expect(subject['q'].last.value).to eq(pea)
        end

        it 'should allow the deletion of associations' do
          grandma.add_var('q')
          mother.add_assoc('q', pea)
          subject.add_assoc('q', ref_x)
          expect(mother.associations.size).to eq(1)
          expect(subject.associations.size).to eq(1)

          subject.clear
          expect(subject.associations).to be_empty

          mother.clear
          expect(mother.associations).to be_empty
        end

        it 'should say fresh when a variable has no association at all' do
          grandma.add_var('q')
          grandma.add_var('x')
          expect(subject.fresh?(ref_q)).to be_truthy
          subject.add_assoc('q', ref_x) # Dependency: q --> x
          expect(subject.fresh?(ref_x)).to be_truthy
        end

        it 'should say not fresh when variable --> atomic value' do
          grandma.add_var('q')
          grandma.add_var('x')
          subject.add_assoc('q', ref_x) # Dependency: q --> x
          expect(subject.fresh?(ref_q)).to be_truthy

          # Associate with an atomic term
          subject.add_assoc('q', pea)
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'should say not fresh when variable --> composite of atomics' do
          grandma.add_var('q')

          # Composite having only atomic terms as leaf elements
          expr = cons(pea, cons(pod))
          subject.add_assoc('q', expr)
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'say not fresh when variable --> composite of atomics & bound var' do
          grandma.add_var('q')
          grandma.add_var('x')
          subject.add_assoc('x', pea) # Dependency: x --> pea
          expr = cons(pea, cons(pod, cons(ref_x)))
          subject.add_assoc('q', expr)
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'say not fresh when variable --> composite of atomics & fresh var' do
          grandma.add_var('q')
          grandma.add_var('x')
          expr = cons(pea, cons(pod, cons(ref_x)))
          subject.add_assoc('q', expr)
          expect(subject.fresh?(ref_q)).to be_truthy
        end

        it 'say not fresh when variables are fused & one is ground' do
          grandma.add_var('q')
          grandma.add_var('x')

          # Beware of cyclic structure
          subject.add_assoc('q', ref_x) # Dependency: q --> x
          subject.add_assoc('x', ref_q) # Dependency: x --> q
          expect(subject.fresh?(ref_x)).to be_truthy
          expect(subject.fresh?(ref_q)).to be_truthy
          expect(subject.associations).to be_empty

          # Associate with an atomic term
          subject.add_assoc('x', pea)
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'should rank names sequentially' do
          2.times do
            expect(subject.get_rank('a')).to eq(0)
            expect(subject.get_rank('z')).to eq(1)
            expect(subject.get_rank('c')).to eq(2)
          end
        end

        it 'should clear the rankings' do
          expect(subject.get_rank('a')).to eq(0)
          expect(subject.get_rank('z')).to eq(1)

          subject.clear_rankings
          expect(grandma.rankings).to be_empty

          expect(subject.get_rank('z')).to eq(0)
          expect(subject.get_rank('a')).to eq(1)
        end

        it 'should provide a String representation of itself' do
          expectation = +"#<#{subject.class}:#{subject.object_id.to_s(16)} @parent="
          expectation << "#<#{subject.parent.class}:#{subject.parent.object_id.to_s(16)}>>"
          expect(subject.inspect).to eq(expectation)
        end
      end # context
    end # describe
  end # module
end # module
