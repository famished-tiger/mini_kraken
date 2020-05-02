# mini_kraken
[![Build Status](https://travis-ci.org/famished-tiger/mini_kraken.svg?branch=master)](https://travis-ci.org/famished-tiger/mini_kraken)
[![Gem Version](https://badge.fury.io/rb/mini_kraken.svg)](https://badge.fury.io/rb/mini_kraken)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/famished-tiger/mini_kraken/blob/master/LICENSE.txt)

### What is __mini_kraken__ ?   
An implemention of the [miniKanren](http://minikanren.org/) relational programming in Ruby.
*miniKanren* is a small language for relational (logic) programming.
Based on the reference implementation, in Scheme from the "The Reasoned Schemer" book.  
Daniel P. Friedman, William E. Byrd, Oleg Kiselyov, and Jason Hemann: "The Reasoned Schemer", Second Edition,
ISBN: 9780262535519, (2018), MIT Press.

### Features
[X] ==  
[X] run\*  
[X] fresh  

### TODO
[-] disj2  
[-] conj2  
[-] conde  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_kraken'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_kraken

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/famished-tiger/mini_kraken.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
