# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../support/factory_atomic'

# Load the class under test
require_relative '../../lib/mini_kraken/composite/cons_cell'

module MiniKraken
  module Composite
    describe ConsCell do
      include MiniKraken::FactoryAtomic # Use mix-in module

      let(:pea) { k_symbol(:pea) }
      let(:pod) { k_symbol(:pod) }
      let(:corn) { k_symbol(:corn) }
      subject { ConsCell.new(pea, pod) }

      context 'Initialization:' do
        it 'could be initialized with one argument' do
          expect { ConsCell.new(pea) }.not_to raise_error
        end

        it 'could be initialized with a second optional argument' do
          expect { ConsCell.new(pea, pod) }.not_to raise_error
        end

        it 'should know its car child' do
          expect(subject.car).to eq(pea)
        end

        it 'should know its cdr child' do
          expect(subject.cdr).to eq(pod)
        end

        it 'should know its children' do
          expect(subject.children).to eq([pea, pod])
        end

        it 'should know if it is empty (null)' do
          expect(subject).not_to be_null
          expect(ConsCell.new(nil, nil)).to be_null
          expect(NullList).to be_null
        end

        it 'simplifies cdr if its referencing a null list' do
          instance = ConsCell.new(pea, NullList)
          expect(instance.car).to eq(pea)
          expect(instance.cdr).to be_nil
        end
      end # context

      context 'Provided services:' do
        it 'should compare to itself' do
          expect(subject.eql?(subject)).to be_truthy
          synonym = subject
          expect(subject == synonym).to be_truthy
        end

        it 'should compare to another instance' do
          same = ConsCell.new(pea, pod)
          expect(subject.eql?(same)).to be_truthy

          different = ConsCell.new(pod, pea)
          expect(subject.eql?(different)).to be_falsey

          different = ConsCell.new(pea)
          expect(subject.eql?(different)).to be_falsey
        end

        it 'should set_cdr! another cons cell' do
          instance = ConsCell.new(pea)
          trail = ConsCell.new(pod)
          instance.set_cdr!(trail)
          expect(instance.car).to eq(pea)
          expect(instance.cdr).to eq(trail)
        end

        it 'should provide a list representation of itself' do
          # Case of null list
          expect(NullList.to_s).to eq '()'

          # Case of one element proper list
          cell = ConsCell.new(pea)
          expect(cell.to_s).to eq '(:pea)'

          # Case of two elements proper list
          cell = ConsCell.new(pea, ConsCell.new(pod))
          expect(cell.to_s).to eq '(:pea :pod)'

          # Case of two elements improper list
          expect(subject.to_s).to eq '(:pea . :pod)'

          # Case of three elements proper list
          cell = ConsCell.new(pea, ConsCell.new(pod, ConsCell.new(corn)))
          expect(cell.to_s).to eq '(:pea :pod :corn)'

          # Case of three elements improper list
          cell = ConsCell.new(pea, ConsCell.new(pod, corn))
          expect(cell.to_s).to eq '(:pea :pod . :corn)'

          # Case of a nested list
          cell = ConsCell.new(ConsCell.new(pea), ConsCell.new(pod))
          expect(cell.to_s).to eq '((:pea) :pod)'
        end
      end # context
    end # describe
  end # module
end # module
