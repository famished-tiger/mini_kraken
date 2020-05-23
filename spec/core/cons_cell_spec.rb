# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/k_symbol'

# Load the class under test
require_relative '../../lib/mini_kraken/core/cons_cell'

module MiniKraken
  module Core
    describe ConsCell do
      let(:pea) { KSymbol.new(:pea) }
      let(:pod) { KSymbol.new(:pod) }
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

        it 'should append another cons cell' do
          instance = ConsCell.new(pea)
          trail = ConsCell.new(pod)
          instance.append(trail)
          expect(instance.car).to eq(pea)
          expect(instance.cdr).to eq(trail)
        end
      end # context
    end # describe
  end # module
end # module
