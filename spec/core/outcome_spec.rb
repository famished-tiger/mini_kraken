# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/vocabulary'

# Load the class under test
require_relative '../../lib/mini_kraken/core/outcome'

module MiniKraken
  module Core
    describe Outcome do
      let(:voc) do
        obj = Object.new
        obj.extend(Vocabulary)
        obj
      end
      subject { Outcome.new(:"#s", voc) }

      context 'Initialization:' do
        it 'should be created with a symbol and a vocabulary' do
          expect { Outcome.new(:"#s", voc) }.not_to raise_error
        end

        it 'should know its resultant' do
          expect(subject.resultant).to eq(:"#s")
        end

        it 'should know its parent' do
          expect(subject.parent).to eq(voc)
        end
      end # context

      context 'Provided services:' do
        it 'should have a factory for failing outcome' do
          instance = Outcome.failure(voc)
          expect(instance.resultant).to eq(:"#u")
          expect(instance.parent).to eq(voc)
        end

        it 'should have a factory for succeeding outcome' do
          instance = Outcome.success(voc)
          expect(instance.resultant).to eq(:"#s")
          expect(instance.parent).to eq(voc)
        end
      end # context
    end # describe
  end # module
end # module
