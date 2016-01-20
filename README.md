# ReSwift

[![Build Status](https://img.shields.io/travis/ReSwift/ReSwift/master.svg?style=flat-square)](https://travis-ci.org/ReSwift/ReSwift) [![Code coverage status](https://img.shields.io/codecov/c/github/ReSwift/ReSwift.svg?style=flat-square)](http://codecov.io/github/ReSwift/ReSwift) [![Cocoapods Compatible](https://img.shields.io/cocoapods/v/ReSwift.svg?style=flat-square)](https://cocoapods.org/pods/ReSwift) [![Platform support](https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20tvos%20%7C%20watchos-lightgrey.svg?style=flat-square)](https://github.com/ReSwift/ReSwift/blob/master/LICENSE.md) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/ReSwift/ReSwift/blob/master/LICENSE.md)

**This library is a pre-release. Expect missing docs and breaking API changes.**

ReSwift is a [Redux](https://github.com/rackt/redux)-like implementation of the unidirectional data flow architecture in Swift. It embraces a unidirectional data flow that only allows state mutations through declarative actions.

### Merge announcement:

**ReduxKit** and **Swift-Flow** have joined forces! The result is **ReSwift**.

_The nitty gritty_: We decided to deprecate [ReduxKit](https://github.com/ReduxKit/ReduxKit) and keep it as a reference implementation of how an almost exact Redux implementation in Swift can be accomplished. It will no longer be actively maintained, but PRs are still welcome.

Swift-Flow has adopted the name **ReSwift** and moved to it's new home as a nod to it's Redux roots that remain at it's core. Going forward, our combined efforts will be focused on ReSwift and surrounding tooling.

# Table of Contents

- [About ReSwift](#about-reswift)
- [Why ReSwift?](#why-reswift)
- [Getting Started Guide](#getting-started-guide)
- [Installation](#installation)
- [Testing](#testing)
- [Demo](#demo)
- [Extensions](#extensions)
- [Example Projects](#example-projects)
- [Credits](#credits)
- [Get in touch](#get-in-touch)

# About ReSwift

ReSwift relies on a few principles:
- **The Store** stores your entire app state in the form of a single data structure. This state can only be modified by dispatching Actions to the store. Whenever the state in the store changes, the store will notify all observers.
- **Actions** are a declarative way of describing a state change. Actions don't contain any code, they are consumed by the store and forwarded to reducers. Reducers will handle the actions by implementing a different state change for each action.
- **Reducers** provide pure functions, that based on the current action and the current app state, create a new app state

![](Readme/Assets/reswift_concept.png)

For a very simple app, that maintains a counter that can be increased and decreased, you can define the app state as following:

```swift
struct AppState: StateType {
    var counter: Int = 0
}
```

You would also define two actions, one for increasing and one for decreasing the counter. In the [Getting Started Guide](Readme/GettingStarted.md) you can find out how to construct complex actions. For the simple actions in this example we can define empty structs that conform to action:

```swift
struct CounterActionIncrease: Action {}
struct CounterActionDecrease: Action {}
```

Your reducer needs to respond to these different action types, that can be done by switching over the type of action:

```swift
struct CounterReducer: Reducer {

    func handleAction(var state: AppState, action: Action) -> AppState {
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

}
```
In order to have a predictable app state, it is important that the reducer is always free of side effects, it receives the current app state and an action and returns the new app state.

Lastly, your view layer, in this case a view controller, needs to tie into this system by subscribing to store updates and emitting actions whenever the app state needs to be changed:

```swift
class CounterViewController: UIViewController, StoreSubscriber {

    @IBOutlet var counterLabel: UILabel!

    override func viewWillAppear(animated: Bool) {
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(animated: Bool) {
        mainStore.unsubscribe(self)
    }

    func newState(state: AppState) {
        counterLabel.text = "\(state.counter)"
    }

    @IBAction func increaseButtonTapped(sender: UIButton) {
        mainStore.dispatch(
            CounterActionIncrease()
        )
    }

    @IBAction func decreaseButtonTapped(sender: UIButton) {
        mainStore.dispatch(
            CounterActionDecrease()
        )
    }

}
```

The `newState` method will be called by the `Store` whenever a new app state is available, this is where we need to adjust our view to reflect the latest app state.

Button taps result in dispatched actions that will be handled by the store and its reducers, resulting in a new app state.

This is a very basic example that only shows a subset of ReSwift's features, read the Getting Started Guide to see how you can build entire apps with this architecture.

[You can also watch this talk on the motivation behind ReSwift](https://realm.io/news/benji-encz-unidirectional-data-flow-swift/).

# Why ReSwift?

Model-View-Controller (MVC) is not a holistic application architecture. Typical Cocoa apps defer a lot of complexity to controllers since MVC doesn't offer other solutions for state management, one of the most complex issues in app development.

Apps built upon MVC often end up with a lot of complexity around state management and propagation. We need to use callbacks, delegations, Key-Value-Observation and notifications to pass information around in our apps and to ensure that all the relevant views have the latest state.

This approach involves a lot of manual steps and is thus error prone and doesn't scale well in complex code bases.

It also leads to code that is difficult to understand at a glance, since dependencies can be hidden deep inside of view controllers. Lastly, you mostly end up with inconsistent code, where each developer uses the state propagation procedure they personally prefer. You can circumvent this issue by style guides and code reviews but you cannot automatically verify the adherence to these guidelines.

ReSwift attempts to solve these problem by placing strong constraints on the way applications can be written. This reduces the room for programmer error and leads to applications that can be easily understood - by inspecting the application state data structure, the actions and the reducers.

This architecture provides further benefits beyond improving your code base:

- Stores, Reducers, Actions and extensions such as ReSwift Router are entirely platform independent - you can easily use the same business logic and share it between apps for multiple platforms (iOS, tvOS, etc.)
- Want to collaborate with a co-worker on fixing an app crash? Use [ReSwift Recorder](https://github.com/ReSwift/ReSwift-Recorder) to record the actions that lead up to the crash and send them the JSON file so that they can replay the actions and reproduce the issue right away.
- Maybe recorded actions can be used to build UI and integration tests?

The ReSwift tooling is still in a very early stage, but aforementioned prospects excite me and hopefully others in the community as well!

# Getting Started Guide

[A Getting Started Guide that describes the core components of apps built with ReSwift lives here](Readme/GettingStarted.md). It will be expanded in the next few weeks. To get an understanding of the core principles I recommend reading the brilliant [redux documentation](http://rackt.org/redux/).

# Installation

## Cocoapods

You can install ReSwift via CocoaPods by adding it to your `Podfile`:

	use_frameworks!

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'

	pod 'ReSwift'

And run `pod install`.

## Carthage

You can install ReSwift via [Carthage]() by adding the following line to your Cartfile:

    github "ReSwift/ReSwift"

# Checking out Source Code and Running Tests

Due to an [issue in Nimble](https://github.com/Quick/Nimble/issues/213) at the moment, tvOS tests will fail if building Nimble / Quick from source. You can however install Nimble & Quick from binaries then rebuild OSX & iOS only. After checkout, run the following from the terminal:

```bash
carthage bootstrap && carthage bootstrap --no-use-binaries --platform ios,osx
```

# Demo

Using this library you can implement apps that have an explicit, reproducible state, allowing you, among many other things, to replay and rewind the app state, as shown below:

![](Readme/Assets/timetravel.gif)

# Extensions

This repository contains the core component for ReSwift, the following extensions are available:

- [ReSwift-Router](https://github.com/ReSwift/ReSwift-Router): Provides a ReSwift compatible Router that allows declarative routing in iOS applications
- [ReSwift-Recorder](https://github.com/ReSwift/ReSwift-Recorder): Provides a `Store` implementation that records all `Action`s and allows for hot-reloading and time travel

# Example Projects

- [CounterExample](https://github.com/ReSwift/CounterExample): A very simple counter app implemented with ReSwift. This app also demonstrates the basics of routing with ReSwiftRouter.
- [Meet](https://github.com/Ben-G/Meet): A real world application being built with ReSwift - currently still very early on.

# Contributing

There's still a lot of work to do here! I would love to see you involved! Some design decisions for the core of ReSwift are still up in the air (see issues), there's lots of useful documentation that can be written and a ton of extensions and tools are waiting to be built on top of ReSwift.

I personally think the best way to get started contributing to this library is by using it in one of your projects!

# Credits

- Thanks a lot to [Dan Abramov](https://github.com/gaearon) for building [Redux](https://github.com/rackt/redux) - all ideas in here and many implementation details were provided by his library.

# Get in touch

If you have any questions, you can find me on twitter [@benjaminencz](https://twitter.com/benjaminencz).
