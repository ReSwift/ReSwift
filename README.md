⚠️ **This framework is a pre-release. Expect missing docs and breaking API changes** ⚠️

Swift Flow is a [Redux](https://github.com/rackt/redux)-like implementation of the unidirectional data flow architecture in Swift.

#Introduction

As in the diagram shown below, the framework provides the infrastructure for `Store`s, `Action`s and `Reducer`s. 

![](Readme/redux.png)

#Installation

You can install SwiftFlow via [Carthage]() by adding the following line to your Cartfile:

	github "Swift-Flow/Swift-Flow"
	
#Extensions

This repository contains the core component for Swift Flow, the following extensions are available:

- [Swift-Flow-Router](https://github.com/Swift-Flow/Swift-Flow-Router): Provides a SwiftFlow compatible Router that allows declarative routing in iOS applications
- [Swift-Flow-Recorder](https://github.com/Swift-Flow/Swift-Flow-Recorder): Provides a `Store` implementation that records all `Action`s and allows for hot-reloading and time travel

#Example Projects

- [CounterExample](https://github.com/Swift-Flow/CounterExample): A very simple counter app implemented with Swift Flow. This app also demonstrates the basics of routing with SwiftFlowRouter.