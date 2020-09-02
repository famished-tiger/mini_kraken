# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/glue/dsl'


module MiniKraken
  module Glue
    describe 'DSL (Chap 2)' do
      include DSL

      context 'Chapter 2 examples:' do
        let(:acorn) { cons(:a, cons(:c, cons(:o, cons(:r, cons(:n))))) }

        it 'accepts caro definition inspired from frame 2:6' do
          # Reasoned S2, frame 2:6
          # (defrel (caro p a)
          #   (fresh (d)
          #   (== (cons a d) p)))

          # As 'p' has a special meaning in Ruby, the argument has been remaned to 'r'
          caro_rel = defrel('caro', %w[r a]) do
            fresh('d', equals(cons(a, d), r))
          end

          expect(caro_rel).to be_kind_of(Core::DefRelation)
          expect(caro_rel.name).to eq('caro')
          expect(caro_rel.arity).to eq(2)
          expect(caro_rel.formals[0].name).to eq('r')
          expect(caro_rel.formals[1].name).to eq('a')
          g_template = caro_rel.goal_template
          expect(g_template).to be_kind_of(FreshEnvFactory)
          expect(g_template.names).to include('d')
        end

        # In Scheme:
        # (defrel (caro p a)
        #   (fresh (d)
        #   (== (cons a d) p)))
        # In Ruby, `p`is a stnadard Kernel method => replaced by `r`
        def defrel_caro
          defrel('caro', %w[r a]) { fresh('d', equals(cons(a, d), r)) }
        end

        it 'passes frame 2:3' do
          defrel_caro

          # (run* q
          #   (caro '(a c o r n) q)) ;; => (a)
          result = run_star('q', caro(acorn, q))
          expect(result.car).to eq(:a)
        end

        it 'passes frame 2:4' do
          defrel_caro

          # (run* q
          #   (caro '(a c o r n) 'a)) ;; => (_0)
          result = run_star('q', caro(acorn, :a))
          expect(result.car).to eq(:_0)
        end

        it 'passes frame 2:5' do
          defrel_caro

          # (run* r
          #   (fresh (x y)
          #     (caro '(,r ,y) x)
          #     (== 'pear x)));; r => (pear)
          result = run_star('r', fresh(%w[x y],
            [caro(cons(r, cons(y)), x),
              equals(:pear, x)]))
          expect(result.car).to eq(:pear)
        end

        it 'passes frame 2:8' do
          defrel_caro

          # (run* r
          #   (fresh (x y)
          #     (caro '(grape raisin pear) x)
          #     (caro '((a) (b) (c)) y)
          #     (== (cons x y) r))) ;; r => ((grape a))
          fruits = cons(:grape, cons(:raisin, cons(:pear)))
          expect(fruits.to_s).to eq('(:grape :raisin :pear)')
          abc = cons(cons(:a), cons(cons(:b), cons(cons(:c))))
          expect(abc.to_s).to eq('((:a) (:b) (:c))')

          result = run_star('r', fresh(%w[x y],
            [caro(fruits, x),
              caro(abc, y),
              equals(cons(x, y), r)]))
          expect(result.car).to eq(cons(:grape, cons(:a)))
        end
      end # context
    end # describe
  end # module
end # module
