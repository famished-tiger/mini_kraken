# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/core/variable_ref'

module MiniKraken
  module Core
    describe VariableRef do
      subject { VariableRef.new('q') }

      context 'Initialization:' do
        it 'should be initialized with the name of variable' do
          expect { VariableRef.new('q') }.not_to raise_error
        end

        it 'should know the name of a variable' do
          expect(subject.var_name).to eq('q')
        end
      end # context

      context 'Provided services:' do
      end # context
    end # describe
  end # module
end # module
