# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/core/succeed'

module MiniKraken
  module Core
    describe Succeed do
      subject { Succeed.instance }

      context 'Initialization:' do
        it 'should have one instance' do
          expect { Succeed.instance }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.name).to eq('succeed')
        end
      end # context

      context 'Provided services:' do
        it 'should unconditionally return a success result' do
          args = double('fake-args')
          env = double('fake-env')
          
          solver = nil
          expect { solver = subject.solver_for(args, env) }.not_to raise_error
          
          # Solver should quack like a Fiber
          dummy_arg = double('dummy-stuff')
          result = solver.resume(dummy_arg)
          expect(result).to eq(BasicSuccess)
          
          # Only one "solution", next 'resume' call should return nil
          result = solver.resume(dummy_arg)
          expect(result).to be_nil          
        end
      end # context
    end # describe
  end # module
end # module
