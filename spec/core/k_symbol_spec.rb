# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require 'ostruct'

# Load the class under test
require_relative '../../lib/mini_kraken/core/k_symbol'

module MiniKraken
  module Core
    describe KSymbol do
      let(:a_value) { :pea }
      subject { KSymbol.new(a_value) }

      context 'Initialization:' do
        it 'should be created with a Ruby symbol' do
          expect { KSymbol.new(a_value) }.not_to raise_error
        end

        it 'should know its value' do
          expect(subject.value).to eq(a_value)
        end

        it 'should know that it is a ground term' do
          env = double('mock-env')
          expect(subject.ground?(env)).to be_truthy
        end
      end # context

      context 'Provided services:' do
        it 'should know whether it is equal to another instance' do
          # Same type, same value
          other = KSymbol.new(a_value)
          expect(subject).to be_eql(other)

          # Same type, other value
          another = KSymbol.new(:pod)
          expect(subject).not_to be_eql(another)

          # Different type, same value
          yet_another = OpenStruct.new(value: :pea)
          expect(subject).not_to be_eql(yet_another)
        end

        it 'should know whether it has same value than other object' do
          # Same type, same value
          other = KSymbol.new(a_value)
          expect(subject == other).to be_truthy

          # Same type, other value
          another = KSymbol.new(:pod)
          expect(subject == another).to be_falsy

          # Same duck type, same value
          yet_another = OpenStruct.new(value: :pea)
          expect(subject == yet_another).to be_truthy

          # Different duck type, different value
          still_another = OpenStruct.new(value: :pod)
          expect(subject == still_another).to be_falsy

          # Default Ruby representation, same value
          expect(subject == :pea).to be_truthy

          # Default Ruby representation, different value
          expect(subject == :pod).to be_falsy
        end
      end # context
    end # describe
  end # module
end # module
