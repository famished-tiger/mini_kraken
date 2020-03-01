# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/goal'
require_relative '../../lib/mini_kraken/core/publisher'
require_relative '../../lib/mini_kraken/dsl/kraken_dsl'
# Load the class under test
require_relative '../../lib/mini_kraken/core/facade' 

module MiniKraken
  module Core
    describe Facade do
      include DSL::KrakenDSL

      let(:a_pub) { Publisher.new }
      let(:a_relation) { Fail.instance }
      subject { Facade.new(a_pub) }

      context 'Initialization:' do
        it 'could have one publisher argument' do
          expect { Facade.new(a_pub) }.not_to raise_error
        end
        
        it 'should know its publisher' do
          expect(subject.publisher).to eq(a_pub)
        end        
      end # context

      context 'Provided services:' do
        it 'should support run* expression' do
          expect(subject.run_star('q', fail)).to be_empty
        end
      end # context
    end # describe
  end # module
end # module