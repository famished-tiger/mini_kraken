## [0.2.01] - 2020-08-07
- The DSL (Domain Specific Language) now supports `defrel` and boolean literals.

### CHANGED
- Constructor `DefRelation#initialize` now freezes any new class instance.  
- Constructor `GoalTemplate#initialize` now freezes any new class instance.  
- Mixin module `Core::DSL` new method `defrel` to build custom relations.
- File `.rubocop.yml` to please Rubocop 0.89

## [0.2.00] - 2020-07-12
- First release of DSL (Domain Specific Language)
- Fix defect for fused variables that remain fresh

### NEW
- Mix-in module `Glue::DSL` hosting methods for implementing the DSL.
- Method `ConsCell#to_s` uses the Lisp convention for representing lists.

### CHANGED
- File `README.md` Added a couple of examples of DSL use.
- Method `AnyValue#==` can compare with symbols with format '_' + integer literal (e.g. :_0).

## [0.1.13] - 2020-07-01
- Cover all frames from Chapter One of "Reasoned Scheme" book.
- Fix defect for fused variables that remain fresh

### CHANGED
- Method `Variable#quote` now takes into account of cases when variables are fused.
- Method `Vocabulary#names_fused`  now copes with cases where no variable with given name can be found.

## [0.1.12] - 2020-06-29
- Supports `conde`, that is, a relation that can take an arbitrary number of arguments.
- Cover all frames but one from Chapter One of "Reasoned Scheme" book.

### New
- Class `Conde` a relation that succeeds for each of its successful arguments.

### CHANGED
- Method `Goal#validated_actuals` add into account polyadic relations (= relations with arbitrary number of arguments)

## [0.1.11] - 2020-06-25
- Supports `defrel`, that is, the capability to define new relations by combining other relations.
- Covers frames from "The Reasoned Scheme" book up to frame [1:87]

### New
- Class `BaseArg` a generalization of goal or goal template argument.
- Class `DefRelation` A specialization of `Relation` class aimed for user-defined relation.
- Class `FormalArg` to represent goal template argument(s).
- Class `FormalRef` an allusion to a formal argument in a goal template.
- Class `GoalTemplate` a representation of a goal parametrized with formal arguments.
- Class `KBoolean` a MiniKraken representation of a boolean value.

### CHANGED
- File `README.md` minor change: added more TODO's.

## [0.1.10] - 2020-06-13
- Supports frames from "The Reasoned Scheme" book up to frame [1:81]

### New
- Factory methods `Outcome#failure`, `Outcome#success`
- Method `Vocabulary#inspect`
- File `outcome_spec.rb`

### FIXED
- `Conj2#conjunction` vocabulary wasn't cleared when outcome2 was nil.

## [0.1.09] - 2020-06-06
- Supports frames from "The Reasoned Scheme" book up to frame [1:76]

### CHANGED
- Method `FreshEnv#initialize`accepts an array of goals as second argument. This array is transformed into a conjunction of goals.
- Method `RunStarExpression#initialize` accepts multiple multiple variable names and goals.
- Method `RunStarExpression#run` can handle solutions with multiple variables.

## [0.1.08] - 2020-05-30
- Fix of nasty bug (object aliasing) that caused flaky failures in specs.

### FIXED
- `DuckFiber#resume` each call returns a distinct `Outcome` instance when successful.

## [0.1.07] - 2020-05-23
- Implementation of `disj2` (two arguments disjunction - or -)

### New
- Class `Disj2` as subclass of `GoalRelation` that implements the disjunction of two subgoals

### CHANGED
- Class `Disj2`: common code with `Conj2` class factored out to superclass `GoalRelation`
- File `cons_cell.rb`: prevent multiple inclusions via different requires
- Method `Vocabulary#ancestor_walker` now returns an `Enumerator` instead of a `Fiber`.

### FIXED
- Method `RunStarExpression#run` clear associations and rankings for second and consecutive solmutions


## [0.1.06] - 2020-05-20
- Implementation of `conj2` (two arguments conjunction - and -)

### New
- Class `CompositeGoal`
- Class `Conj2` as subclass of `GoalRelation` that implements the conjunction of two subgoals
- Mixin module `Designation` to factor out the common methods in `Variable` and `VariableRef` classes
- Class `GoalArg` abstract class, that is a generalization for anything that be be argument of a goal.
- Class `GoalRelation` as subclass of `Relation`. A goal that is linked to a such relation may have goals as its arguments only.

### Changed
- Class `Goal` is new subclass of class `GoalArg`. Therefore a goal can be an argument to another goal.
- Class `Term` is new subclass of class `GoalArg`. Therefore a term can be an argument of a goal.
- Classes `Variable`, `VariableRef` now include mix-in module `Designation`
- File `cd_implementation.txt` Updated with changes of class relationship

## [0.1.05] - 2020-05-09
- Changed implementation of fused variables  
- Magic comments for frozen string literal
- Code re-styling to please Rubocop 0.82

### Changed
- File `README.md` Added "What is mini_kraken" text.
- File `README.md` Added badges (CI Travis build status, Gem version, license)

## [0.1.04] - 2020-05-02
### Changed
- File `README.md` Added "What is mini_kraken" text.
- File `README.md` Added badges (CI Travis build status, Gem version, license)

## [0.1.03] - 2020-05-01
Passes all frames 1:1 up to 1:47 of "Reasoned Schemer" book

### Fixed
- Fresh variables are now correctly 'reified' according to the convention in "Reasoned Schemer".

## [0.1.02] - 2020-04-28
Major code refactoring. Passes all frames 1:1 up to 1:36 of "Reasoned Schemer" book

## [0.1.01] - 2020-03-01
First code commit
### Added
- In `Core` module: `Facade`, `Fail`, `FormalArg`, `Goal`, `NullaryRelation`, `Publisher`, `Relation`, `RunStarExpression`, `Succeed`, `Variable`
- File `CHANGELOG.md`. This file. Adopting `keepachangelog.com` recommended format.
- File `min_kraken.gemspec` Updated gem description.

## [0.1.0] - 2020-02-05
### Added
- Initial Github commit as new project