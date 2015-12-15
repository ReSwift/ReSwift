#Getting Started with Swift Flow

Swift Flow provides the infrastructure for `Store`s, `Action`s and `Reducer`s to enable a unidirectional data flow as shown below. 

![](Assets/redux.png)

The following steps will describe how to set up the individual components for your Swift Flow app.

#State

The application state is defined in a single data structure which should be a struct. This struct can have other structs as members, that allows you to add different sub-states as your app grows. 

The state struct should store your entire application state, that includes the UI state, the navigation state and the state of your model layer. 

Here's an example of a state struct as defined in the [Counter Example](https://github.com/Swift-Flow/CounterExample):

```swift
struct AppState: StateType, HasNavigationState {
    var counter: Int = 0
    var navigationState = NavigationState()
}
```

There are multiple things to note:

1. Your app state struct needs to conform to the `StateType` protocol, currently this is just a marker protocol, but we will likely add requirements (such as the ability to [serialize the state](https://github.com/Swift-Flow/Swift-Flow/issues/3)) before v1.0.
2. If you are including `SwiftRouter` in your project, your app state needs to conform to the `HasNavigationState` protocol. This means you need to add a property called `navigationState` to your state struct. This is the sub-state the router will use to store the current route. 

##Viewing the State Through a Protocol

Protocols are extremely useful for working with this framework. As you can see in the example above, `SwiftRouter` can work with any app state that you define, as long as it conforms to the `HasNavigationState` protocol. The router will only ever access your app state through this protocol - this also means it won't ever see and depend upon any other state that you store within your state struct.

**You should use this approach as much as possible in your app.** Swift Flow provides some features that make this approach even easier to use. Let's say you want to expand the state above by a simple authentication state. You would do this by first defining a new struct for this sub-state:

```swift
struct AuthenticationState {
	var userAuthenticated = false
}
```

*Additionally,* you would define a protocol that requires your app state to include the `AuthenticationState`:

```swift
struct HasAuthenticationState {
	var authenticationState: AuthenticationState
}
```
Now you can extend your state using this protocol:

```swift
struct AppState: StateType, HasNavigationState, HasAuthenticationState {
    var counter: Int = 0
    var navigationState = NavigationState()
    var authenticationState = AuthenticationState()
}
```

If you now add a view (or any other subscriber) that is only interested in this particular substate, you should express this within your `newState` method (that is the callback for all subscribers in Swift Flow).

You would implement the `newState` method as following:

```swift
    func newState(state: HasAuthenicationState) {
        loggedInLabel.text = "\(state.authenticationState.userAuthenticated)"
    }
```
Swift Flow will infer the type that you have required and will automatically cast your app state to that type - this means the particular subscriber will only see the required substate, not any other state in your app. **This approach will help you reduce dependencies on state that should be irrelevant to your component**.

Currently your method is not called if the state cannot be casted into the required type - [we're considering changing this into a `fatalError` as it will make debugging easier](). 

##Derived State

Note that you don't need to store derived state inside of your app state. E.g. instead of storing a `UIImage` you should store a image URL that can be used to fetch the image from a cache or via a download. The app state should store all the information that uniquely identifies the current state and allows it to be reconstructed, but none that can be easily derived. 


#Actions

Swift Flow provides the `Action` type to create actions that describe state changes. It has the following structure:

```swift
struct Action : ActionType {
	let type: String
   	let payload: [String : AnyObject]?
}
```
This `Action` type is serializable, which is imported for storing past actions to disk and enabling time traveling and hot reloading. 

For simple actions you can use this type directly; for actions with a complex payload you should make use of Swift's rich type system and create separate type. This type needs to be convertible into plain `Action`s.
