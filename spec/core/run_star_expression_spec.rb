# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

require_relative '../../lib/mini_kraken/core/variable'
require_relative '../../lib/mini_kraken/core/fail'
require_relative '../../lib/mini_kraken/core/goal'
# Load the class under test
require_relative '../../lib/mini_kraken/core/run_star_expression' 

module MiniKraken
  module Core
    describe RunStarExpression do
      let(:a_var) { Variable.new('q') }
      let(:a_relation) { Fail.instance }      
      let(:a_goal) { Goal.new(a_relation, []) }
      subject { RunStarExpression.new(a_var, a_goal) }

      context 'Initialization:' do
        it 'could have one variable and a goal' do
          expect { RunStarExpression.new(a_var, a_goal) }.not_to raise_error
        end
        
        it 'should know its variables' do
          expect(subject.vars['q']).to eq(a_var)
        end
        
        it 'should know its goal' do
          expect(subject.goal).to eq(a_goal)
        end        
      end # context

      context 'Provided services:' do
        it 'should unify the variable(s) with the given goal' do
          pub = double('fake-publisher')
          expect(pub).to receive(:broadcast_entry).with(a_goal, subject.vars)
          expect(pub).to receive(:broadcast_exit).with(a_goal, subject.vars, [])          
          expect(subject.run(pub)).to be_empty
        end      
      end # context
    end # describe
  end # module
end # module