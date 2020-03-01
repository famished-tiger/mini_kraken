# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/dsl/kraken_dsl' 

module MiniKraken
  module DSL
    describe KrakenDSL do
      subject do 
        obj = Object.new
        obj.extend(KrakenDSL)
      end

      context 'Attaching mix-in:' do
        it 'should extend object' do
          obj = Object.new
          expect { obj.extend(KrakenDSL) }.not_to raise_error
        end
      end # context

      context 'Provided services:' do
        it "should provide the 'fail' goal constructor" do
          expect(subject.fail).to be_kind_of(Core::Goal)
          expect(subject.fail.relation.name).to eq('fail')
        end
      end # context
    end # describe
  end # module
end # module