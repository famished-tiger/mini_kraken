# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/core/fail' 

module MiniKraken
  module Core
    describe Fail do
      subject { Fail.instance }

      context 'Initialization:' do
        it 'should have one instance' do
          expect { Fail.instance }.not_to raise_error
        end
        
        it 'should know its name' do
          expect(subject.name).to eq('fail')
        end
      end # context

      context 'Provided services:' do
      end # context
    end # describe
  end # module
end # module