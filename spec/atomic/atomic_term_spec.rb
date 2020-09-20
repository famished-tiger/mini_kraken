# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require 'ostruct'

# Load the class under test
require_relative '../../lib/mini_kraken/atomic/atomic_term'

module MiniKraken
  module Atomic
    describe AtomicTerm do
      let(:a_value) { :serenity }
      let(:other_value) { :fuzziness }
      subject { AtomicTerm.new(a_value) }

      context 'Initialization:' do
        it 'should be created with a Ruby datatype instance' do
          expect { AtomicTerm.new(a_value) }.not_to raise_error
        end

        it 'knows its value' do
          expect(subject.value).to eq(a_value)
        end

        it 'freezes its value' do
          expect(subject.value).to be_frozen
        end
      end # context

      context 'Provided services:' do
        it 'should know that it is a ground term' do
          env = double('mock-env')
          expect(subject.ground?(env)).to be_truthy
        end

        it 'should know that it is not a fresh term' do
          env = double('mock-env')
          expect(subject.fresh?(env)).to be_falsy
        end

        it 'should know its freshness' do
          env = double('mock-env')
          expect(subject.freshness(env).degree).to eq(:ground)
        end

        it 'performs data value comparison' do
          expect(subject == subject).to be_truthy
          expect(subject == subject.value).to be_truthy

          expect(subject == other_value).to be_falsy
          expect(subject == AtomicTerm.new(other_value)).to be_falsy

          # Same duck type, same value
          yet_another = OpenStruct.new(value: a_value)
          expect(subject == yet_another).to be_truthy

          # Same duck type, different value
          still_another = OpenStruct.new(value: other_value)
          expect(subject == still_another).to be_falsy
        end

        it 'performs type and data value comparison' do
          expect(subject).to be_eql(subject)

          # Same type, same value
          other = AtomicTerm.new(a_value)
          expect(subject).to be_eql(other)

          # Same type, other value
          another = AtomicTerm.new(other_value)
          expect(subject).not_to be_eql(another)

          # Different type, same value
          yet_another = OpenStruct.new(value: other_value)
          expect(subject).not_to be_eql(yet_another)
        end

        it 'returns itself when receiving quote message' do
          env = double('mock-env')
          expect(subject.quote(env)).to eq(subject)
        end
      end # context
=begin
      # An atomic term is by definition a ground term: since it doesn't contain
      # any bound variable (in Prolog sense).
      # @param _env [Vocabulary]
      # @return [Freshness]
      def freshness(_env)
        Freshness.new(:ground, self)
      end
=end
    end # describe
  end # module
end # module
