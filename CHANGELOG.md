## [0.1.06] - 2020-05-20
- Implementation of `conj2` (two arguments conjunction)

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