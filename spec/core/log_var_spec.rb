# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/environment'

# Load the class under test
require_relative '../../lib/mini_kraken/core/log_var'


module MiniKraken
  module Core
    describe LogVar do
      let(:env) { Environment.new }
      subject { LogVar.new('q') }

      context 'Initialization:' do
        it 'should be initialized with a name' do
          expect { LogVar.new('q') }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('q')
        end

        it 'should be fresh by default' do
          env.add_var(subject)
          expect(subject.fresh?(env)).to be_truthy
        end
      end # context

      context 'Provided services:' do
      end # context
    end # describe
  end # module
end # module
