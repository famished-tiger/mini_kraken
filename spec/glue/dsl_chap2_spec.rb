# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/mini_kraken/glue/dsl'


module MiniKraken
  module Glue
    describe 'DSL (Chap 2)' do
      include DSL

      context 'Chapter 2 examples:' do
        # ((:a) (:b) (:c))
        let(:abc) { cons(cons(:a), cons(cons(:b), cons(cons(:c)))) }

        # '(:a :c :o :r :n)
        let(:acorn) { cons(:a, cons(:c, cons(:o, cons(:r, cons(:n))))) }

        # '(:c :o :r :n)
        let(:corn) { cons(:c, cons(:o, cons(:r, cons(:n)))) }

        # '(:grape :raisin :pear)'
        let(:fruits) { cons(:grape, cons(:raisin, cons(:pear))) }

        let(:uuid_pattern) do
          /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
        end

        it 'accepts caro definition inspired from frame 2:6' do
          # Reasoned S2, frame 2:6
          # (defrel (caro p a)
          #   (fresh (d)
          #   (== (cons a d) p)))

          # As 'p' has a special meaning in Ruby, the argument has been renamed to 'r'
          caro_rel = defrel('caro', %w[r a], fresh('d', unify(cons(a, d), r)))

          # Check side-effect from DSL
          expect(instance_variable_get(:@defrels)['caro']).to eq(caro_rel)

          # Check results of defrel
          expect(caro_rel).to be_kind_of(Rela::DefRelation)
          expect(caro_rel.name).to eq('caro')
          expect(caro_rel.arity).to eq(2)
          expect(caro_rel.formals[0]).to match(/^r_/)
          expect(caro_rel.formals[0]).to match(uuid_pattern)
          expect(caro_rel.formals[1]).to match(/^a_/)
          expect(caro_rel.formals[1]).to match(uuid_pattern)
          g_template = caro_rel.expression

          # Checking the 'fresh' part
          expect(g_template).to be_kind_of(Core::Goal)
          expect(g_template.relation).to be_kind_of(Rela::Fresh)
          expect(g_template.actuals[0]).to eq('d')
          fresh_2nd_actual = g_template.actuals[1]

          # Checking the (== (cons a d) r) sub-expression
          expect(fresh_2nd_actual).to be_kind_of(Core::Goal)
          expect(fresh_2nd_actual.relation.name).to eq('unify')
          expect(fresh_2nd_actual.actuals[0]).to be_kind_of(Composite::ConsCell)
          expect(fresh_2nd_actual.actuals[0].to_s).to match(/^\(a_[-0-9a-f]+ \. d\)$/)
          expect(fresh_2nd_actual.actuals[1]).to be_kind_of(Core::LogVarRef)
          expect(fresh_2nd_actual.actuals[1].name).to match(/^r_[-0-9a-f]+$/)
        end

        # In Scheme:
        # (defrel (caro p a)
        #   (fresh (d)
        #   (== p (cons a d))))
        # In Ruby, `p`is a standard Kernel method => replace it by `r`
        def defrel_caro
          defrel('caro', %w[r a], fresh('d', unify(r, cons(a, d))))
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

        # IT FAILS
        it 'passes frame 2:5' do
          defrel_caro

          # (run* r
          #   (fresh (x y)
          #     (caro '(,r ,y) x)
          #     (== 'pear x)));; r => (pear)
          result = run_star('r', fresh(%w[x y],
            [caro(cons(r, cons(y)), x),
              unify(:pear, x)]))
          expect(result.car).to eq(:pear)
        end

        it 'passes frame 2:8' do
          defrel_caro

          # (run* r
          #   (fresh (x y)
          #     (caro '(grape raisin pear) x)
          #     (caro '((a) (b) (c)) y)
          #     (== (cons x y) r))) ;; r => ((grape a))

          result = run_star('r', fresh(%w[x y],
            [caro(fruits, x),
              caro(abc, y),
              unify(cons(x, y), r)]))
          expect(result.car).to eq(cons(:grape, cons(:a)))
        end

        it 'accepts cdro definition inspired from frame 2:13' do
          # Reasoned S2, frame 2:13
          # (defrel (cdro p d)
          #   (fresh (a)
          #   (== (cons a d) p)))

          # As 'p' has a special meaning in Ruby, the argument has been remaned to 'r'
          cdro_rel = defrel('cdro', %w[r d], fresh('a', unify(cons(a, d), r)))

          expect(cdro_rel).to be_kind_of(Rela::DefRelation)
          expect(cdro_rel.name).to eq('cdro')
          expect(cdro_rel.arity).to eq(2)
          expect(cdro_rel.formals[0]).to match(/^r_[-0-9a-f]+$/)
          expect(cdro_rel.formals[1]).to match(/^d_[-0-9a-f]+$/)
          g_template = cdro_rel.expression
          expect(g_template.relation).to be_kind_of(Rela::Fresh)
          expect(g_template.actuals).to include('a')
        end

        # In Scheme:
        # (defrel (cdro p d)
        #   (fresh (a)
        #   (== p (cons a d))))
        # In Ruby, `p`is a standard Kernel method => replace it by `r`
        def defrel_cdro
          defrel('cdro', %w[r d], fresh('a', unify(r, cons(a, d))))
        end

        it 'passes unnesting process in frame 2:12' do
          defrel_caro
          defrel_cdro

          # (run* r
          #   (fresh (v)
          #     (cdro '(acorn) v)
          #     (fresh (w)
          #       (cdro v w)
          #       (caro w r))) ;; r => (o)

          result = run_star('r', fresh('v',
            [cdro(acorn, v),
              fresh('w',
                [cdro(v, w),
                  caro(w, r)])]))
          expect(result.car).to eq(:o)
        end

        it 'passes frame 2:15' do
          defrel_caro
          defrel_cdro

          # (run* r
          #   (fresh (x y)
          #     (cdro '(grape raisin pear) x)
          #     (caro '((a) (b) (c)) y)
          #     (== (cons x y) r))) ;; r => (((raisin pear) a))

          result = run_star('r', fresh(%w[x y],
            [cdro(fruits, x),
              caro(abc, y),
              unify(cons(x, y), r)]))
          expect(result.to_s).to eq('(((:raisin :pear) :a))')
        end

        it 'passes frame 2:16' do
          defrel_cdro

          # (run* q
          #   (cdro '(a c o r n) '(c o r n))) ;; => (_0)
          result = run_star('r', cdro(acorn, corn))
          expect(result.car).to eq(:_0)
        end

        it 'passes frame 2:17' do
          defrel_cdro

          # (run* x
          #   (cdro '(c o r n) '(,x r n))) ;; => (o)
          result = run_star('x', cdro(corn, cons(x, cons(:r, cons(:n)))))
          expect(result.car).to eq(:o)
        end

        it 'passes frame 2:18' do
          defrel_caro
          defrel_cdro

          # (run* l
          #   (fresh (x)
          #     (cdro l '(c o r n))
          #     (caro l x)
          #     (== 'a x))) ;; l => ('(a c o r n))

          result = run_star('l', fresh('x',
            [cdro(l, corn),
              caro(l, x),
              unify(:a, x)]))
          expect(result.to_s).to eq('((:a :c :o :r :n))')
        end

        it 'accepts conso definition inspired from frame 2:25' do
          defrel_caro
          defrel_cdro

          # Reasoned S2, frame 2:25
          # (defrel (conso a p d)
          #   (caro  p a)
          #   (cdro p d))

          # As 'p' has a special meaning in Ruby, the argument has been renamed
          # to 'r'
          conso_rel = defrel('conso', %w[a d r], [caro(r, a), cdro(r, d)])

          expect(conso_rel).to be_kind_of(Rela::DefRelation)
          expect(conso_rel.name).to eq('conso')
          expect(conso_rel.arity).to eq(3)
          expect(conso_rel.formals[0]).to match(/^a_[-0-9a-f]+$/)
          expect(conso_rel.formals[1]).to match(/^d_[-0-9a-f]+$/)
          expect(conso_rel.formals[2]).to match(/^r_[-0-9a-f]+$/)
          g_template = conso_rel.expression
          expect(g_template.relation).to be_kind_of(Rela::Conj2)
          g1 = g_template.actuals[0]
          expect(g1).to be_kind_of(Core::Goal)
          expect(g1.relation.name).to eq('caro')
          expect(g1.actuals[0].name).to match(/^r_/)
          expect(g1.actuals[1].name).to match(/^a_/)

          g2 = g_template.actuals[1]
          expect(g2).to be_kind_of(Core::Goal)
          expect(g2.relation.name).to eq('cdro')
          expect(g2.actuals[0].name).to match(/^r_/)
          expect(g2.actuals[1].name).to match(/^d_/)
        end


        def defrel_conso
          defrel_caro
          defrel_cdro

          # Definition derived from frame 2:25
          # In Scheme:
          # (defrel (conso a d p)
          #   (caro  p a)
          #   (cdro p d))
          # In Ruby, `p`is a standard Kernel method => replace it by `r`
          # defrel('conso', %w[a d r], [caro(r, a), cdro(r, d)])

          # Definition derived from frame 2:26
          defrel('conso', %w[a d r], [unify(cons(a, d), r)])
        end

        it 'passes frame 2:19' do
          defrel_conso

          # (run* l
          #   (conso '(a b c) '(d e) l)) ;; => (((a b c) d e))

          result = run_star('l', conso(list(:a, :b, :c), list(:d, :e), l))
          expect(result.to_s).to eq('(((:a :b :c) :d :e))')
        end

        it 'passes frame 2:20' do
          defrel_conso

          # (run* x
          #   (conso x '(a b c) '(d a b c))) ;; => (d)

          result = run_star('x', conso(x, list(:a, :b, :c), list(:d, :a, :b, :c)))
          expect(result.to_s).to eq('(:d)')
        end

        it 'passes frame 2:21' do
          defrel_conso

          # (run* r
          #   (fresh (x y z)
          #     (== '(e a d ,x) r)
          #     (conso y '(a ,z c) r))) ;; => ((e a d c)

          expr = fresh(%w[x y z],
            [unify(list(:e, :a, :d, x), r),
              conso(y, list(:a, z, :c), r)])
          result = run_star('r', expr)
          expect(result.to_s).to eq('((:e :a :d :c))')
        end

        it 'passes frame 2:22' do
          defrel_conso

          # (run* x
          #   (conso x '(a ,x c) '(d a ,x c))) ;; => (d)

          result = run_star('x', conso(x, list(:a, x, :c), list(:d, :a, x, :c)))
          expect(result.to_s).to eq('(:d)')
        end

        it 'passes frame 2:23' do
          defrel_conso

          # (run* l
          #   (fresh (x)
          #     (== '(d a ,x c) l)
          #     (conso x '(a ,x c) l))) ;; => ((d a d c)

          expr = fresh(%w[x],
            [unify(list(:d, :a, x, :c), l),
              conso(x, list(:a, x, :c), l)])
          result = run_star('l', expr)
          expect(result.to_s).to eq('((:d :a :d :c))')
        end

        it 'passes frame 2:24' do
          defrel_conso

          # (run* l
          #   (fresh (x)
          #     (conso x '(a ,x c) l)))
          #     (== '(d a ,x c) l) ;; => ((d a d c)

          expr = fresh(%w[x],
            [conso(x, list(:a, x, :c), l),
              unify(list(:d, :a, x, :c), l)])
          result = run_star('l', expr)
          expect(result.to_s).to eq('((:d :a :d :c))')
        end

        # it 'passes frame 2:25' do
          # defrel_conso

          # # (run* l
          # #   (fresh (d t x y w)
          # #     (conso w '(n u s) t)
          # #     (cdro l t)
          # #     (caro l x)
          # #     (== 'b x)
          # #     (cdro l d)
          # #     (caro d y)
          # #     (== 'o y))) ;; => ((b o n u s))

          # expr = fresh(%w[d t x y w],
            # [conso(w, list(:n, :u, :s), t),
              # cdro(l, t),
              # caro(l, x),
              # unify(:b, x),
              # cdro(l, d),
              # caro(d, y),
              # unify(:o, y)])
          # result = run_star('l', expr)
          # expect(result.to_s).to eq('((:b :o :n :u :s))')
        # end

        it 'accepts nullo definition inspired from frame 2:33' do
          # Reasoned S2, frame 2:33
          # (defrel (nullo x)
          #   (==  '() x)

          nullo_rel = defrel('nullo', %w[x], unify(null, x))

          expect(nullo_rel).to be_kind_of(Rela::DefRelation)
          expect(nullo_rel.name).to eq('nullo')
          expect(nullo_rel.arity).to eq(1)
          expect(nullo_rel.formals[0]).to match(/^x_[-0-9a-f]+$/)
          g_template = nullo_rel.expression
          expect(g_template.relation).to be_kind_of(Rela::Unify)
          expect(g_template.actuals[0]).to be_null
          expect(g_template.actuals[1]).to be_kind_of(Core::LogVarRef)
          expect(g_template.actuals[1].name).to match(/^x_[-0-9a-f]+$/)
        end

        def defrel_nullo
          # Definition derived from frame 2:33
          defrel('nullo', %w[x], unify(null_list, x))
        end

        it 'passes frame 2:30' do
          defrel_nullo

          # (run* q
          #   (nullo '(grape raisin pear))) ;; => ()

          result = run_star('q', nullo(list(:grape, :raisin, :pear)))
          expect(result).to be_null
        end

        it 'passes frame 2:31' do
          defrel_nullo

          # (run* q
          #   (nullo '())) ;; => (_0)

          result = run_star('q', nullo(null_list))
          expect(result.to_s).to eq('(_0)')
        end

        it 'passes frame 2:32' do
          defrel_nullo

          # (run* x
          #   (nullo x)) ;; => (())

          result = run_star('x', nullo(x))
          expect(result.to_s).to eq('(())')
        end

        it 'passes frame 2:35' do
          defrel_nullo

          # (run* r
          #   (fresh (x y)
          #     (== (cons x (cons y 'salad)) r))) ;; => ((_0 _1 . salad))

          result = run_star('r', fresh(%w[x y],
            unify(cons(x, cons(y, :salad)), r)))
          expect(result.to_s).to eq('((_0 _1 . :salad))')
        end

        it 'passes frame 2:45' do
          defrel_nullo

          # (run* r
          #   (fresh (x y)
          #     (== (cons x (cons y 'salad)) r))) ;; => ((_0 _1 . salad))

          result = run_star('r', fresh(%w[x y],
            unify(cons(x, cons(y, :salad)), r)))
          expect(result.to_s).to eq('((_0 _1 . :salad))')
        end

        it 'accepts pairo definition inspired from frame 2:46' do
          defrel_conso

          # Reasoned S2, frame 2:46
          # (defrel (pairo r)
          #   (fresh (a d)
          #     (conso a d r)))

          pairo_rel = defrel('pairo', %w[r],fresh(%w[a d], conso(a, d, r)))

          expect(pairo_rel).to be_kind_of(Rela::DefRelation)
          expect(pairo_rel.name).to eq('pairo')
          expect(pairo_rel.arity).to eq(1)
          expect(pairo_rel.formals[0]).to match(/^r_[-0-9a-f]+$/)
          g_template = pairo_rel.expression
          expect(g_template.relation).to be_kind_of(Rela::Fresh)
          expect(g_template.actuals[0]).to eq(%w[a d])
          expect(g_template.actuals[1]).to be_kind_of(Core::Goal)
          expect(g_template.actuals[1].relation.name).to eq('conso')
          expect(g_template.actuals[1].actuals[0].name).to eq('a')
          expect(g_template.actuals[1].actuals[1].name).to eq('d')
          expect(g_template.actuals[1].actuals[2].name).to match(/^r_[-0-9a-f]+$/)
        end

        def defrel_pairo
          defrel_conso

          # Definition derived from frame 2:46
          defrel('pairo', %w[r],fresh(%w[a d], conso(a, d, r)))
        end

        it 'passes frame 2:47' do
          defrel_pairo

          # (run* q
          #   (pairo (cons q q))) ;; => (_0)

          result = run_star('q', pairo(cons(q, q)))
          expect(result.to_s).to eq('(_0)')
        end
        
        it 'passes frame 2:48' do
          defrel_pairo

          # (run* q
          #   (pairo '())) ;; => ()

          result = run_star('q', pairo(null_list))
          expect(result.to_s).to eq('()')
        end

        it 'passes frame 2:49' do
          defrel_pairo

          # (run* q
          #   (pairo 'pair)) ;; => ()

          result = run_star('q', pairo(:pair))
          expect(result.to_s).to eq('()')
        end

        it 'passes frame 2:50' do
          defrel_pairo

          # (run* x
          #   (pairo x)) ;; => ((_0 . _1))

          result = run_star('x', pairo(x))
          expect(result.to_s).to eq('((_0 . _1))')
        end

        it 'passes frame 2:51' do
          defrel_pairo

          # (run* r
          #   (pairo (cons r '()))) ;; => (_0)

          result = run_star('r', pairo(cons(r, null_list)))
          expect(result.to_s).to eq('(_0)')
        end         
      end # context
    end # describe
  end # module
end # module
