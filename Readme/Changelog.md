# Changelog

## Upcoming release

> Unreleased changes in [`master`](https://github.com/ReSwift/ReSwift) scheduled to be integrated into the next release.

**API Changes:**

- `SwiftFlowInit` action has been renamed to `ReSwiftInit` - @vfn

**Other:**

- Update Documentation. Sample reducer code was slightly outdated - @vfn

## [0.2.4](https://github.com/ReSwift/ReSwift/releases/tag/0.2.4)

*Released: 01/23/2015*

**API Changes:**

- Pass typed store reference into `ActionCreator`. `ActionCreator` can now access `Store`s state without the need for typecasts - @Ben-G
- `Store` can now be initialized with an empty state, allowing reducers to hydrate the store - @Ben-G

**Bugfixes**

- Break retain cycle when using middelware - @sendyhalim

**Other:**

- Update Documentation to reflect renaming to ReSwift - @agentk
- Documentation fixes - @orta and @sendyhalim
- Refactoring - @dcvz and @sendyhalim
