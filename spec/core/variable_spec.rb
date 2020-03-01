# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/core/variable' 

module MiniKraken
  module Core
    describe Variable do
      subject { Variable.new('q') }

      context 'Initialization:' do
        it 'should be initialized with a name' do
          expect { Variable.new('q') }.not_to raise_error
        end
        
        it 'should know its name' do
          expect(subject.name).to eq('q')
        end
      end # context

      context 'Provided services:' do
      end # context
    end # describe
  end # module
end # module