[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Swift-Flow/Swift-Flow/blob/master/LICENSE.md)

⚠️ **This library is a pre-release. Expect missing docs and breaking API changes** ⚠️

#Table of Contents

- [Getting Started Guide](#getting-started-guide)
- [Installation](#installation)
- [Demo](#demo)
- [Extensions](#extensions)
- [Example Projects](#example-projects)
- [Credits](#credits)
- [Get in touch](#get-in-touch)


#About Swift Flow

![](Readme/Assets/swift_flow_concept.png)

#Getting Started Guide

[A Getting Started Guide that describes the core components of apps built with Swift Flow lives here](Readme/GettingStarted.md). It will be expanded in the next few weeks. To get an understanding of the core principles I recommend reading the brilliant [redux documentation](http://rackt.org/redux/).

#Installation

You can install SwiftFlow via [Carthage]() by adding the following line to your Cartfile:

	github "Swift-Flow/Swift-Flow"
	
#Demo

Swift Flow is a [Redux](https://github.com/rackt/redux)-like implementation of the unidirectional data flow architecture in Swift.

Using this library you can implement apps that have an explicit, reproducible state, allowing you, among many other things, to replay and rewind the app state, as shown below:

![](Readme/Assets/timetravel.gif)
	
#Extensions

This repository contains the core component for Swift Flow, the following extensions are available:

- [Swift-Flow-Router](https://github.com/Swift-Flow/Swift-Flow-Router): Provides a SwiftFlow compatible Router that allows declarative routing in iOS applications
- [Swift-Flow-Recorder](https://github.com/Swift-Flow/Swift-Flow-Recorder): Provides a `Store` implementation that records all `Action`s and allows for hot-reloading and time travel

#Example Projects

- [CounterExample](https://github.com/Swift-Flow/CounterExample): A very simple counter app implemented with Swift Flow. This app also demonstrates the basics of routing with SwiftFlowRouter.
- [Meet](https://github.com/Ben-G/Meet): A real world application being built with Swift Flow - currently still very early on.

#Credits

- Thanks a lot to [Dan Abramov](https://github.com/gaearon) for building redux - all ideas in here and many implementation details were provided by his library.

#Get in touch

If you have any questions, you can find me on twitter [@benjaminencz](https://twitter.com/benjaminencz).