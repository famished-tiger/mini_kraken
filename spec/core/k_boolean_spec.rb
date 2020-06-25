# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require 'ostruct'

# Load the class under test
require_relative '../../lib/mini_kraken/core/k_boolean'

module MiniKraken
  module Core
    describe KBoolean do
      subject { KBoolean.new('#t') }

      context 'Initialization:' do
        it 'could be created with a Ruby true/false value' do
          expect { KBoolean.new(true) }.not_to raise_error
          expect { KBoolean.new(false) }.not_to raise_error
        end

        it 'could be created with a Ruby Symbol value' do
          expect { KBoolean.new(:"#t") }.not_to raise_error
          expect { KBoolean.new(:"#f") }.not_to raise_error
        end

        it 'could be created with a Ruby String value' do
          expect { KBoolean.new('#t') }.not_to raise_error
          expect { KBoolean.new('#f') }.not_to raise_error
        end

        it 'should know its value' do
          expect(subject.value).to eq(true)
        end

        it 'should know that it is a ground term' do
          env = double('mock-env')
          expect(subject.ground?(env)).to be_truthy
        end
      end # context

      context 'Provided services:' do
        it 'should know whether it is equal to another instance' do
          # Same type, same value
          other = KBoolean.new(true)
          expect(subject).to be_eql(other)

          other = KBoolean.new(:"#t")
          expect(subject).to be_eql(other)

          other = KBoolean.new('#t')
          expect(subject).to be_eql(other)

          # Same type, other value
          another = KBoolean.new(false)
          expect(subject).not_to be_eql(another)

          # Same type, other value
          another = KBoolean.new(:"#f")
          expect(subject).not_to be_eql(another)

          # Same type, other value
          another = KBoolean.new('#f')
          expect(subject).not_to be_eql(another)

          # Different type, same value
          yet_another = OpenStruct.new(value: true)
          expect(subject).not_to be_eql(yet_another)
        end

        it 'should know whether it has same value than other object' do
          # Same type, same value
          other = KBoolean.new(true)
          expect(subject == other).to be_truthy

          other = KBoolean.new(:"#t")
          expect(subject == other).to be_truthy

          other = KBoolean.new('#t')
          expect(subject == other).to be_truthy

          # Same type, other value
          another = KBoolean.new(false)
          expect(subject == another).to be_falsy

          another = KBoolean.new(:"#f")
          expect(subject == another).to be_falsy

          another = KBoolean.new('#f')
          expect(subject == another).to be_falsy

          # Same duck type, same value
          yet_another = OpenStruct.new(value: true)
          expect(subject == yet_another).to be_truthy

          # Different duck type, different value
          still_another = OpenStruct.new(value: false)
          expect(subject == still_another).to be_falsy

          # Default Ruby representation, same value
          expect(subject == true).to be_truthy

          # Default Ruby representation, different value
          expect(subject == false).to be_falsy
        end
      end # context
    end # describe
  end # module
end # module
