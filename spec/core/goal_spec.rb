# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/fail'

# Load the class under test
require_relative '../../lib/mini_kraken/core/goal'

module MiniKraken
  module Core
    describe Goal do
      let(:a_relation) { Fail.instance }
      subject { Goal.new(a_relation, []) }

      context 'Initialization:' do
        it 'should accept one goal and argument array' do
          expect { Goal.new(a_relation, []) }.not_to raise_error
        end

        it 'should know its relation' do
          expect(subject.relation).to eq(a_relation)
        end
      end # context

      context 'Provided services:' do
        it 'should attain its intended purpose' do
          pub = double('fake-publisher')
          expect(pub).to receive(:broadcast_entry).with(subject, [])
          expect(pub).to receive(:broadcast_exit).with(subject, [], [])
          expect(subject.attain(pub, [])).to eq([])
        end
      end # context
    end # describe
  end # module
end # module