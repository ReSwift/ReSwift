# 4.0.0

*Work in Progress*

**Breaking API Changes:**

- Introduced a new Subscription API (#203) - @Ben-G, @mjarvis, @DivineDominion

  - The subscription API provides basic operators, such as `skipRepeats` (skip calls to `newState` unless state value changed) and `select` (sub-select a state).

  - This is a breaking API change that requires migrating existing subscriptions that sub-select a portion of a store's state:

    - Subselecting state in 3.0.0:

      ```swift
      store.subscribe(subscriber) { ($0.testValue, $0.otherState?.name) }
      ```
    - Subselecting state in 4.0.0:

      ```swift
      store.subscribe(subscriber) {
        $0.select {
          ($0.testValue, $0.otherState?.name)
        }
      }
      ```

  - For any store state that is `Equatable` or any sub-selected state that is `Equatable`, `skipRepeats` will be used by default.

  - For states/substates that are not `Equatable`, `skipRepeats` can be implemented via a closure:

    ```swift
    store.subscribe(subscriber) {
      $0.select {
          $0.testValue
          }.skipRepeats {
              return $0 == $1
          }
    }
    ```

- Reducer type has been removed in favor of reducer function (#177) - Ben-G

  - Here's an example of a new app reducer, for details see the README:

    ```swift
    func counterReducer(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()

        switch action {
        case _ as CounterActionIncrease:
            state.counter += 1
        case _ as CounterActionDecrease:
            state.counter -= 1
        default:
            break
        }

        return state
    }
    ```

- `dispatch` functions now return `Void` instead of `Any` (#187) - @Qata

  - The return type has been removed without any replacement, since the core team did not find any use cases of it. A common usage of the return type in redux is returning a promise that is fullfilled when a dispatched action is processed. While it's generally discouraged to disrupt the unidirectional data flow using this mechanism we do provide a `dispatch` overload that takes a `callback` argument and serves this purpose.

- Make `dispatch` argument in middleware non-optional (#225) -  @dimazen, @mjarvis, @Ben-G


**Other:**

- Extend `StoreType` with substate selector subscription (#192) - @mjarvis
- Add `DispatchingStoreType` protocol for testing (#197) - @mjarvis
- Installation guide for Swift Package Manager - @thomaspaulmann
- Update documentation to reflect breaking API changes - @mjarvis
- Clarify error message on concurrent usage of ReSwift - @langford

# 3.0.0

*Released: 11/12/2016*

**Breaking API Changes:**
- Dropped support for Swift 2.2 and lower (#157) - @Ben-G

**API Changes:**
- Mark `Store` as `open`, this reverts a previously accidental breaking API Change (#157) - @Ben-G

**Other**:
- Update to Swift 3.0.1 - @Cristiam, @Ben-G
- Documentation changes - @vkotovv

# 2.1.0

*Released: 09/15/2016*

**Other**:

- Swift 3 preview compatibility, maintaining Swift 2 naming - (#126) - @agentk
- Xcode 8 GM Swift 3 Updates (#149) - @tkersey
- Migrate Quick/Nimble testing to XCTest - (#127) - @agentk
- Automatically build docs via Travis CI (#128) - @agentk
- Documentation Updates & Fixes- @mikekavouras, @ColinEberhardt

# 2.0.0

*Released: 06/27/2016*

**Breaking API Changes**:

- Significant Improvements to Serialization Code for `StandardAction` (relevant for recording tools) - @okla

**Other**:

- Swift 2.3 Updates - @agentk
- Documentation Updates & Fixes - @okla, @gregpardo, @tomj, @askielboe, @mitsuse, @esttorhe, @RyanCCollins, @thomaspaulmann, @jlampa


# 1.0.0

*Released: 03/19/2016*

**API Changes:**
- Remove callback arguments on synchronous dispatch methods - @Ben-G

**Other:**

- Move all documentation source into `Docs`, except `Readme`, `Changelog` and `License` - @agentk
- Replace duplicated documentation with an enhanced `generate_docs.sh` build script - @agentk
- Set CocoaPods documentation URL - (#56) @agentk
- Update documentation for 1.0 release - @Ben-G

# 0.2.5

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

# 0.2.4

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
