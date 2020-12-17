# MiniKraken
[![Build Status](https://travis-ci.org/famished-tiger/mini_kraken.svg?branch=master)](https://travis-ci.org/famished-tiger/mini_kraken)
[![Gem Version](https://badge.fury.io/rb/mini_kraken.svg)](https://badge.fury.io/rb/mini_kraken)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/famished-tiger/mini_kraken/blob/master/LICENSE.txt)

### What is __mini_kraken__ ?   
A library containing an implementation in Ruby of the [miniKanren](http://minikanren.org/) 
 language.
*miniKanren* is a small language for relational (logic) programming as defined in the "The Reasoned Schemer" book.   
Daniel P. Friedman, William E. Byrd, Oleg Kiselyov, and Jason Hemann: "The Reasoned Schemer", Second Edition,
ISBN: 9780262535519, (2018), MIT Press.

### Features
- Pure Ruby implementation, not a port from another language
- Object-Oriented design
- No runtime dependencies
- Test suite patterned on the examples from the reference book.

### miniKanren Features
- [X] ==  
- [X] run\*  
- [X] fresh
- [X] conde
- [X] conj2  
- [X] disj2
- [X] defrel  
- [X] caro
- [X] cdro

### TODO

- [ ] Occurs check

List-centric relations from Chapter 2
- [ ] conso  
- [ ] nullo  
- [ ] pairo  
- [ ] singletono  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_kraken'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_kraken

## Examples

The following __MiniKraken__ examples use its DSL (Domain Specific Language).

### Example 1
Let's first begin with a rather simplistic example.   

```ruby
require 'mini_kraken' # Load MiniKraken library

extend(MiniKraken::Glue::DSL) # Add DSL method to self (object in context)

result = run_star('q', unify(q, :pea))
puts result # => (:pea)
```

The two first lines in the above code snippet are pretty standard:  
- The first line loads the `mini_kraken` library.
- The second line add the DSL methods to the current object.

The next line constitutes a trivial `miniKanren` program.  
The aim of a `miniKanren` program is to find one or more solutions involving the given logical variable(s)
and satisfying one or more goals to the `run_star method.  
In our example, the `run_star` method instructs `MiniKraken` to find all solutions,  
knowing that each successful solution:
- binds a value to the provided variable `q` and
- meets the goal `unify(q, :pea)`.

The goal `unify(q, :pea)` succeeds because the logical variable `q` is _fresh_ (that is,
  not yet bound to a value) and will be bound to the symbol `:pea` as a side effect
  of the goal `unify`.

So the above program succeeds and the only found solution is obtained by binding
 the variable `q` to the value :pea. Hence the result of the `puts` method.

### Example 2
 The next example illustrates the behavior of a failing `miniKanren` program.

 ```ruby
 require 'mini_kraken' # Load MiniKraken library

 extend(MiniKraken::Glue::DSL) # Add DSL method to self (object in context)

 # Following miniKanren program fails
 result = run_star('q', [unify(q, :pea), unify(q, :pod)])
 puts result # => ()
 ```
In this example, we learn that `run_star` can take multiple goals placed in an array.
The program fails to find a solution since it is not possible to satisfy the two `unify` goals simultaneously.  
In case of failure, the `run_star` returns an empty list represented as `()` in the output.


### Example 3
 The next example shows the use two logical variables.

```ruby
# In this example and following, one assumes that DSL is loaded as shown in Example 1

result = run_star(['x', 'y'], [unify(:hello, x), unify(y, :world)])
puts result # => ((:hello :world))
```

This time, `run_star` takes two logical variables -`x` and `y`- and successfully finds the solution `x = :hello, y = :world`.

### Example 4
 The next example shows the use of `disj2` goals.
 ```ruby
 result = run_star(['x', 'y'],
                   [
                     disj2(unify(x, :blue), unify(x, :red)),
                     disj2(unify(y, :sea), unify(:mountain, y))
                   ])
 puts result # => ((:blue :sea) (:blue :mountain) (:red :sea) (:red :mountain))
 ```

 Here, `run_star` takes two logical variables and two `disj2` goals.  
 A `disj2` succeeds if any of its arguments succeeds.  
 This program finds four distinct solutions for x, y pairs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/famished-tiger/mini_kraken.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
