#Upcoming Release

**Other**:

- Swift 3 preview compatibility, maintaining Swift 2 naming - (#126) @agentk
- Migrate Quick/Nimble testing to XCTest - (#127) @agentk

#2.0.0

*Released: 06/27/2016*

**Breaking API Changes**:

- Significant Improvements to Serialization Code for `StandardAction` (relevant for recording tools) - @okla

**Other**:

- Swift 2.3 Updates - @agentk
- Documentation Updates & Fixes - @okla, @gregpardo, @tomj, @askielboe, @mitsuse, @esttorhe, @RyanCCollins, @thomaspaulmann, @jlampa


#1.0.0

*Released: 03/19/2016*

**API Changes:**
- Remove callback arguments on synchronous dispatch methods - @Ben-G

**Other:**

- Move all documentation source into `Docs`, except `Readme`, `Changelog` and `License` - @agentk
- Replace duplicated documentation with an enhanced `generate_docs.sh` build script - @agentk
- Set CocoaPods documentation URL - (#56) @agentk
- Update documentation for 1.0 release - @Ben-G

#0.2.5

*Released: 02/20/2016*

**API Changes:**

- Subscribers can now sub-select a state when they subscribe to the store (#61) - @Ben-G
- Rename initially dispatched Action to `ReSwiftInit` - @vfn

**Fixes:**

- Fix retain cycle caused by middleware (issue: #66) - @Ben-G
- Store now holds weak references to subscribers to avoid unexpected memory managegement behavior (issue: #62) - @vfn
- Documentation Fixes - @victorpimentel, @vfn, @juggernate, @raheelahmad

**Other:**

- We now have a [hosted documentation for ReSwift](http://reswift.github.io/ReSwift/master/) - @agentk
- Refactored subscribers into a explicit `Subscription` typealias - @DivineDominion
- Refactored `dispatch` for `AsyncActionCreator` to avoid duplicate code - @sendyhalim

#0.2.4

*Released: 01/23/2016*

**API Changes:**

- Pass typed store reference into `ActionCreator`. `ActionCreator` can now access `Store`s state without the need for typecasts - @Ben-G
- `Store` can now be initialized with an empty state, allowing reducers to hydrate the store - @Ben-G

**Bugfixes**

- Break retain cycle when using middelware - @sendyhalim

**Other:**

- Update Documentation to reflect renaming to ReSwift - @agentk
- Documentation fixes - @orta and @sendyhalim
- Refactoring - @dcvz and @sendyhalim
