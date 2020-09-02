# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/mini_kraken/core/environment'

# Load the class under test
require_relative '../../lib/mini_kraken/core/duck_fiber'

module MiniKraken
  module Core
    describe DuckFiber do
      subject { DuckFiber.new(:failure) }

      context 'Initialization:' do
        it 'should be initialized with a symbol and an optional block' do
          expect { DuckFiber.new(:failure) }.not_to raise_error

          expect { DuckFiber.new(:custom) { Outcome.new(:"#s") } }.not_to raise_error
        end

        it 'should know its outcome' do
          expect(subject.outcome).to eq(Failure)
        end
      end # context

      context 'Provided services:' do
        let(:parent) { Environment.new }

        it 'should behave like a Fiber yielding a failure' do
          failing = DuckFiber.new(:failure)
          outcome = nil
          expect { outcome = failing.resume }.not_to raise_error
          expect(outcome).to eq(Failure)

          # Only one result should be yielded
          expect(failing.resume).to be_nil
        end

        it 'should behave like a Fiber yielding a basic success' do
          succeeding = DuckFiber.new(:success)
          outcome = nil
          expect { outcome = succeeding.resume }.not_to raise_error
          expect(outcome).to be_success
          expect(outcome.parent).to be_nil

          # Only one result should be yielded
          expect(succeeding.resume).to be_nil
        end

        it 'should yield a distinct success object' do
          instance1 = DuckFiber.new(:success)
          outcome1 = instance1.resume

          instance2 = DuckFiber.new(:success)
          outcome2 = instance2.resume

          expect(outcome1).not_to be_equal(outcome2)
        end

        it 'should behave like a Fiber yielding a custom outcome' do
          tailored = DuckFiber.new(:custom) { Outcome.new(:"#s", parent) }
          outcome = nil
          expect { outcome = tailored.resume }.not_to raise_error
          expect(outcome).to eq(Outcome.new(:"#s", parent))

          # Only one result should be yielded
          expect(tailored.resume).to be_nil
        end
      end # context
    end # describe
  end # module
end # module
