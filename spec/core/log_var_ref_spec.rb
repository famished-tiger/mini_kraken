# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/core/log_var_ref'

module MiniKraken
  module Core
    describe LogVarRef do
      subject { LogVarRef.new('q') }

      context 'Initialization:' do
        it 'should be initialized with the name of variable' do
          expect { LogVarRef.new('q') }.not_to raise_error
        end

        it 'should know the name of a variable' do
          expect(subject.var_name).to eq('q')
        end
      end # context

      context 'Provided services:' do
        it 'knows its text representation' do
          expect(subject.to_s).to eq('q')
        end
      end # context
    end # describe
  end # module
end # module
