#Contributing to ReSwift

Some design decisions for the core of ReSwift are still up in the air (see [issues](https://github.com/ReSwift/ReSwift/issues)), there's lots of useful documentation that can be written and a ton of extensions and tools are waiting to be built on top of ReSwift.

Pull requests are welcome on the [`master`](https://github.com/ReSwift/ReSwift) branch.

We know making you first pull request can be scary. If you have trouble with any of the contribution rules, **still make the Pull Request**. We are here to help.

We personally think the best way to get started contributing to this library is by using it in one of your projects!

## Swift style guide

We follow the [Ray Wenderlich Style Guide](https://github.com/raywenderlich/swift-style-guide) very closely with the following exception:

- Use the Xcode default of 4 spaces for indentation.

## SwiftLint

[SwiftLint](https://github.com/realm/SwiftLint) runs automatically on all pull requests via [houndci.com](https://houndci.com/). If you have SwiftLint installed, you will receive the same warnings in Xcode at build time, that hound will check for on pull requests.

Function body lengths in tests will often cause a SwiftLint warning. These can be handled on a per case bases by prefixing the function with:

```swift
// swiftlint:disable function_body_length
func someFunctionThatShouldHaveAReallyLongBody() {}
```

Common violations to look out for are trailing white and valid docs.

## Tests

All code going into master requires testing. We keep code coverage at 100% to ensure the best possibility that all edge cases are tested for. It's good practice to test for any variations that can cause nil to be returned.

Tests are run in [Travis CI](https://travis-ci.org/ReSwift/ReSwift) automatically on all pull requests, branches and tags. These are the same tests that run in Xcode at development time.

## Comments

- **Readable code should be preferred over commented code.**

    Comments in code are used to document non-obvious use cases. For example, when the use of a piece of code looks unnecessary, and naming alone does not convey why it is required.

- **Comments need to be updated or removed if the code changes.**

    If a comment is included, it is just as important as code and has the same technical debt weight. The only thing worse than a unneeded comment is a comment that is not maintained.

## Code documentation

Code documentation is different from comments. Please be liberal with code docs.

When writing code docs, remember they are:

- Displayed to a user in Xcode quick help
- Used to generate API documentation
- API documentation also generates Dash docsets

In particular paying attention to:

- Keeping docs current
- Documenting all parameters and return types (SwiftLint helps with warning when they are not valid)
- Stating common issues that a user may run into

See [NSHipster Swift Documentation](http://nshipster.com/swift-documentation/) for a good reference on writing documentation in Swift.

## Generating documentation

The documentation at `reswift.github.io/ReSwift` is generated from by combining the markdown documentation files with generated documentation using [jazzy](https://github.com/realm/jazzy).

The markdown files used to generated documentation are:

- README.md
- CONTRIBUTING.md
- CHANGELOG.md
- LICENSE.md
- Docs/
    - Getting Started Guide.md
    - templates/
        - heading.md
        - toc.md

Along with the Documentation sections, API sections also support extra documentation found in:

- Docs/
    - Actions.md
    - Reducers.md
    - State.md
    - Stores.md
    - Utilities.md

Each of the markdown files are processed by the `generate_docs.sh` script and saved into `Docs/tmp/` ready for jazzy to generate the final documentation.

The processing of each file can include:

- Extracting a single section (ie, for splitting up README.md)
- Adding a title
- Replacing \{\{version\}\} with the current version
- Ad-hoc string replacements (found in .jazzy.json under "string-replacements")

A forked version of Jazzy is currently used to support individual markdown sections and injecting markdown into API section headers. It can be installed from [https://github.com/agentk/jazzy/](https://github.com/agentk/jazzy/tree/integrated-markdown).

The documentation is hosted by GitHub pages under the [ReSwift gh-pages](https://github.com/ReSwift/ReSwift/tree/gh-pages) branch. The `build.sh` script in the `gh-pages` branch, installs / updates jazzy, checks out the latest master branch of ReSwift, and calls the `generated_docs.sh` script to generate docs into the master folder. Docs changes can then be committed and pushed to the `gh-pages` branch.

The custom jazzy theme is located in: `Docs/jazzy-theme`.

Changes to `generate_docs.sh` will generally only be needed when sections / files are added or removed.

### Documentation TL;DR

To generate docs locally:

```bash
./generate_docs.sh # -> Output to doc_output
```

To update the GitHub pages documentation:

```bash
git clone https://github.com/ReSwift/ReSwift.git --branch gh-pages ReSwift-gh-pages
cd ReSwift-gh-pages
./build.sh
# Documentation is ready to be committed.
```

