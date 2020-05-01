# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/association'
require_relative '../../lib/mini_kraken/core/k_symbol'
require_relative '../../lib/mini_kraken/core/variable_ref'
require_relative '../support/factory_methods'

# Load the class under test
require_relative '../../lib/mini_kraken/core/vocabulary'


module MiniKraken
  module Core

    class TestVocabulary
      include Vocabulary

      def initialize(aParent = nil)
        init_vocabulary(aParent)
      end
    end # class

    module VariableBearer
      attr_reader :vars

      def init_var_bearer
        @vars = {}
        self
      end

      def add_var(aVarName)
        vars[aVarName] = aVarName.hash # Just for testing purposes
      end
    end # module

    describe Vocabulary do
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
        let(:pea) { KSymbol.new(:pea) }
        let(:pod) { KSymbol.new(:pod) }
        let(:ref_q) { VariableRef.new('q') }
        let(:ref_x) { VariableRef.new('x') }
        let(:grandma) do
          voc = TestVocabulary.new
          voc.extend(VariableBearer)
          voc.init_var_bearer
        end
        let(:mother) { TestVocabulary.new(grandma) }
        subject { TestVocabulary.new(mother) }

        it 'should provide a walker over ancestors' do
          walker = subject.ancestor_walker
          expect(walker).to be_kind_of(Fiber)
          expect(walker.resume).to eq(subject)
          expect(walker.resume).to eq(mother)
          expect(walker.resume).to eq(grandma)
          expect(walker.resume).to be_nil
        end

        it 'should know if a variable is defined' do
          expect(subject.include?('q')).to be_falsey
          grandma.add_var('x')
          expect(subject.include?('q')).to be_falsey
          expect(grandma.include?('x')).to be_truthy
          expect(mother.include?('x')).to be_truthy
          expect(subject.include?('x')).to be_truthy
          subject.extend(VariableBearer)
          subject.init_var_bearer
          subject.add_var('y')
          expect(subject.include?('y')).to be_truthy
          expect(mother.include?('y')).to be_falsey
        end

        it 'should allow the addition of associations' do
          grandma.add_var('q')
          expect(subject['q']).to be_empty
          mother.add_assoc(Association.new('q', pea))
          expect(subject['q'].size).to eq(1)
          expect(subject['q'].first.value).to eq(pea)

          subject.add_assoc(Association.new('q', ref_x))
          expect(subject['q'].size).to eq(2)
          expect(subject['q'].first.value).to eq(ref_x)
          expect(subject['q'].last.value).to eq(pea)
        end

        it 'should allow the deletion of associations' do
          grandma.add_var('q')
          mother.add_assoc(Association.new('q', pea))
          subject.add_assoc(Association.new('q', ref_x))
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
          subject.add_assoc(Association.new('q', ref_x)) # Dependency: q --> x
          expect(subject.fresh?(ref_x)).to be_truthy
        end

        it 'should say not fresh when variable --> atomic value' do
          grandma.add_var('q')
          grandma.add_var('x')
          subject.add_assoc(Association.new('q', ref_x)) # Dependency: q --> x
          expect(subject.fresh?(ref_q)).to be_truthy

          # Associate with an atomic term
          subject.add_assoc(Association.new('q', pea))
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'should say not fresh when variable --> composite of atomics' do
          grandma.add_var('q')

          # Composite having only atomic terms as leaf elements
          expr = cons(pea, cons(pod))
          subject.add_assoc(Association.new('q', expr))
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'say not fresh when variable --> composite of atomics & bound var' do
          grandma.add_var('q')
          grandma.add_var('x')
          subject.add_assoc(Association.new('x', pea)) # Dependency: x --> pea
          expr = cons(pea, cons(pod, cons(ref_x)))
          subject.add_assoc(Association.new('q', expr))
          expect(subject.fresh?(ref_q)).to be_falsey
        end

        it 'say not fresh when variable --> composite of atomics & fresh var' do
          grandma.add_var('q')
          grandma.add_var('x')
          expr = cons(pea, cons(pod, cons(ref_x)))
          subject.add_assoc(Association.new('q', expr))
          expect(subject.fresh?(ref_q)).to be_truthy
        end

        it 'say not fresh when variables are fused & one is ground' do
          grandma.add_var('q')
          grandma.add_var('x')

          # Beware of cyclic structure
          subject.add_assoc(Association.new('q', ref_x)) # Dependency: q --> x
          subject.add_assoc(Association.new('x', ref_q)) # Dependency: x --> q
          expect(subject.fresh?(ref_x)).to be_truthy
          expect(subject.fresh?(ref_q)).to be_truthy

          # Associate with an atomic term
          subject.add_assoc(Association.new('x', pea))
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
      end # context
    end # describe
  end # module
end # module
