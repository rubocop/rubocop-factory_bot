# Changelog

## Master (Unreleased)

- Add `ExplicitOnly` configuration option to `FactoryBot/ConsistentParenthesesStyle`. ([@ydah])

## 2.22.0 (2023-05-04)

- Extracted from `rubocop-rspec` into a separate repository for easier use with Minitest/Cucumber. ([@ydah])

## Previously (see [rubocop-rspec's changelist](https://github.com/rubocop/rubocop-rspec/blob/70a97b1895ce4b9bcd6ff336d5d343ddc6175fe6/CHANGELOG.md) for details)

- Fix a false positive for `RSpec/FactoryBot/ConsistentParenthesesStyle` inside `&&`, `||` and `:?` when `omit_parentheses` is on ([@dmitrytsepelev])
- Add new `RSpec/FactoryBot/FactoryNameStyle` cop. ([@ydah])
- Fix wrong autocorrection in `n_times` style on `RSpec/FactoryBot/CreateList`. ([@r7kamura])
- Fix a false positive for `RSpec/FactoryBot/ConsistentParenthesesStyle` when using `generate` with multiple arguments. ([@ydah])
- Fix `RSpec/FactoryBot/ConsistentParenthesesStyle` to ignore calls without the first positional argument. ([@pirj])
- Fix `RSpec/FactoryBot/ConsistentParenthesesStyle` to ignore calls inside a Hash or an Array. ([@pirj])
- Fix an incorrect autocorrect for `FactoryBot/ConsistentParenthesesStyle` with `omit_parentheses` option when method name and first argument are not on same line. ([@ydah])
- Add `RSpec/FactoryBot/ConsistentParenthesesStyle` cop. ([@Liberatys])
- Support `Array.new(n)` on `RSpec/FactoryBot/CreateList` cop. ([@r7kamura])
- Fixed false offense detection in `FactoryBot/CreateList` when a n.times block is including method calls in the factory create arguments. ([@ngouy])
- Fix error in `RSpec/RSpec/FactoryBot/CreateList` cop for empty block. ([@tejasbubane])
- Fix `RSpec/FactoryBot/SyntaxMethods` and `RSpec/Capybara/FeatureMethods` to inspect shared groups. ([@pirj])
- Add new `RSpec/FactoryBot/SyntaxMethods` cop. ([@leoarnold])
- Change namespace of several cops (`Capybara/*` -> `RSpec/Capybara/*`, `FactoryBot/*` -> `RSpec/FactoryBot/*`, `Rails/*` -> `RSpec/Rails/*`). ([@pirj], [@bquorning])
- Fix `FactoryBot/AttributeDefinedStatically` to allow `#traits_for_enum` without a block. ([@harrylewis])
- Improve the performance of `FactoryBot/AttributeDefinedStatically`, `RSpec/InstanceVariable`, `RSpec/LetSetup`, `RSpec/NestedGroups` and `RSpec/ReturnFromStub`. ([@andrykonchin])
- Improve message and description of `FactoryBot/FactoryClassName`. ([@ybiquitous])
- Fix `FactoryBot/FactoryClassName` to ignore `Hash` and `OpenStruct`. ([@jfragoulis])
- Add `FactoryBot/FactoryClassName` cop. ([@jfragoulis])
- Fix `FactoryBot/AttributeDefinedStatically` not working with an explicit receiver. ([@composerinteralia])
- Fix `FactoryBot/CreateList` autocorrect crashing when the factory is called with a block=. ([@Darhazer])
- `FactoryBot/CreateList` now ignores `times` blocks with an argument. ([@Darhazer])
- Fix `FactoryBot/AttributeDefinedStatically` not working when there is a non-symbol key. ([@vzvu3k6k])
- Fix false negative in `FactoryBot/AttributeDefinedStatically` when attribute is defined on `self`. ([@Darhazer])
- `RSpec/FactoryBot` cops will now also inspect the `spec/factories.rb` path by default. ([@bquorning])
- Add `FactoryBot/AttributeDefinedStatically` cop to help FactoryBot users with the deprecation of static attributes. ([@composerinteralia], [@seanpdoyle])
- Remove `FactoryBot/DynamicAttributeDefinedStatically` and `FactoryBot/StaticAttributeDefinedDynamically` cops. ([@composerinteralia])
- Fix `FactoryBot/DynamicAttributeDefinedStatically` false positive when using symbol proc argument for a sequence. ([@tdeo])
- Add `FactoryBot/CreateList` cop. ([@Darhazer])
- Fix `FactoryBot/StaticAttributeDefinedDynamically` to handle empty block. ([@abrom])
- Fix false positive in `FactoryBot/DynamicAttributeDefinedStatically` when a before/after callback has a symbol proc argument. ([@abrom])
- Fix `FactoryBot/DynamicAttributeDefinedStatically` to handle dynamic attributes inside arrays/hashes. ([@abrom])
- Add `FactoryBot/StaticAttributeDefinedDynamically` (based on dynamic attribute cop). ([@abrom])
- Rename namespace `FactoryGirl` to `FactoryBot` following original library update. ([@walf443])
- Add `RSpec/FactoryGirl` namespace including the first cop for factories: `FactoryGirl/DynamicAttributeDefinedStatically`. ([@jonatas])

<!-- Contributors (alphabetically) -->

[@abrom]: https://github.com/abrom
[@andrykonchin]: https://github.com/andrykonchin
[@bquorning]: https://github.com/bquorning
[@composerinteralia]: https://github.com/composerinteralia
[@darhazer]: https://github.com/Darhazer
[@dmitrytsepelev]: https://github.com/dmitrytsepelev
[@harrylewis]: https://github.com/harrylewis
[@jfragoulis]: https://github.com/jfragoulis
[@jonatas]: https://github.com/jonatas
[@leoarnold]: https://github.com/leoarnold
[@liberatys]: https://github.com/Liberatys
[@ngouy]: https://github.com/ngouy
[@pirj]: https://github.com/pirj
[@r7kamura]: https://github.com/r7kamura
[@seanpdoyle]: https://github.com/seanpdoyle
[@tdeo]: https://github.com/tdeo
[@tejasbubane]: https://github.com/tejasbubane
[@vzvu3k6k]: https://github.com/vzvu3k6k
[@walf443]: https://github.com/walf443
[@ybiquitous]: https://github.com/ybiquitous
[@ydah]: https://github.com/ydah
