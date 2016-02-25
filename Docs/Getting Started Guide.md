# Getting Started with ReSwift

ReSwift provides the infrastructure for `Store`s, `Action`s and `Reducer`s to enable a unidirectional data flow as shown below.

![](img/reswift_detail.png)

The following steps will describe how to set up the individual components for your ReSwift app.

# State

The application state is defined in a single data structure which should be a struct. This struct can have other structs as members, that allows you to add different sub-states as your app grows.

The state struct should store your entire application state, that includes the UI state, the navigation state and the state of your model layer.

Here's an example of a state struct as defined in the [Counter Example](https://github.com/ReSwift/CounterExample):

```swift
struct AppState: StateType, HasNavigationState {
    var counter: Int = 0
    var navigationState = NavigationState()
}
```

There are multiple things to note:

1. Your app state struct needs to conform to the `StateType` protocol, currently this is just a marker protocol, but we will likely add requirements (such as the ability to [serialize the state](https://github.com/ReSwift/ReSwift/issues/3)) before v1.0.
2. If you are including `SwiftRouter` in your project, your app state needs to conform to the `HasNavigationState` protocol. This means you need to add a property called `navigationState` to your state struct. This is the sub-state the router will use to store the current route.

## Viewing the State Through a Protocol

Protocols are extremely useful for working with this library. As you can see in the example above, `SwiftRouter` can work with any app state that you define, as long as it conforms to the `HasNavigationState` protocol. The router will only ever access your app state through this protocol - this also means it won't ever see and depend upon any other state that you store within your state struct.

**You should use this approach as much as possible in your app.** ReSwift provides some features that make this approach even easier to use. Let's say you want to expand the state above by a simple authentication state. You would do this by first defining a new struct for this sub-state:

```swift
struct AuthenticationState {
    var userAuthenticated = false
}
```

*Additionally,* you would define a protocol that requires your app state to include the `AuthenticationState`:

```swift
protocol HasAuthenticationState {
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

If you now add a view (or any other subscriber) that is only interested in this particular substate, you should express this within your `newState` method (that is the callback for all subscribers in ReSwift).

You would implement the `newState` method as following:

```swift
    func newState(state: HasAuthenicationState) {
        loggedInLabel.text = "\(state.authenticationState.userAuthenticated)"
    }
```
ReSwift will infer the type that you have required and will automatically cast your app state to that type - this means the particular subscriber will only see the required substate, not any other state in your app. **This approach will help you reduce dependencies on state that should be irrelevant to your component**.

Currently your method is not called if the state cannot be casted into the required type - [we're considering changing this into a `fatalError` as it will make debugging easier](https://github.com/ReSwift/ReSwift/issues/4).

## Derived State

Note that you don't need to store derived state inside of your app state. E.g. instead of storing a `UIImage` you should store a image URL that can be used to fetch the image from a cache or via a download. The app state should store all the information that uniquely identifies the current state and allows it to be reconstructed, but none that can be easily derived.


# Actions

Actions are used to express intended state changes. Actions don't contain functions, instead they provide information about the intended state change, e.g. which user should be deleted.

In your ReSwift app you will define actions for every possible state change that can happen.

Reducers handle these actions and implement state changes based on the information they provide.

All actions in ReSwift conform to the `Action` protocol, which currently is just a marker protocol.

You can either provide custom types as actions, or you can use the built in `StandardAction`.

The `StandardAction` has the following structure:

```swift
struct StandardAction: Action {
    // identifies the action
    let type: String
    // provides information that is relevant to processing this action
    // e.g. details about which post should be favorited
    let payload: [String : AnyObject]?
    // this flag is used for serialization when working with ReSwift Recorder
    let isTypedAction: Bool
}
```
**For most applications it is recommended to create your own types for actions instead of using `StandardAction`, as this allows you to take advantage of Swift's type system**.

To provide your own action, simply create a type that conforms to the `Action` protocol:

```swift
struct LikePostAction: Action {
    let post: Post
    let userLikingPost: User
}
```

The advantage of using a `StandardAction` is that it can be serialized; this is required for using the features provided by [ReSwift Recorder](https://github.com/ReSwift/ReSwift-Recorder); such as persisting the application state between app launches.

If you want to use custom types for actions, but still want to be able to make use of the features provided by ReSwift Recorder, you can implement the `StandardActionConvertible` protocol. This will allow ReSwift to convert your typed actions to standard actions that can then be serialized.

Once ReSwift Recorder's implementation is further along, you will find detailed information  on all of this in its documentation.

# Reducers

This is the only place where you should modify application state! Reducers, just as `StoreSubscribers` can define the particular slice of the app state that they are interested in by changing the type in their `handleAction` method. Here's an example of a part of a reducer in an app built with ReSwift:

```swift
struct DataMutationReducer: Reducer {

    func handleAction(state: HasDataState, action: Action) -> HasDataState {
        switch action {
        case let action as CreateContactWithEmail:
            return createContact(state, email: action.email)
        case let action as CreateContactWithTwitterUser:
            return createContact(state, twitterUser: action.twitterUser)
        case let action as DeleteContact:
            return deleteContact(state, identifier: action.contactID)
        case let action as SetContacts:
            return setContacts(state, contacts: action.contacts)
        default:
            return state
        }
    }

    func createContact(var state: HasDataState, email: String) -> HasDataState {
        let newContactID = state.dataState.contacts.count + 1
        let newContact = Contact(identifier: newContactID, emailAddress: email)
        state.dataState.contacts.append(newContact)

        return state
    }

    func createContact(var state: HasDataState, twitterUser: TwitterUser) -> HasDataState {
        let newContactID = state.dataState.contacts.count + 1
        let newContact = Contact(identifier: newContactID, twitterHandle: twitterUser.username)
        state.dataState.contacts.append(newContact)

        return state
    }
```

You typically switch over the types in `handleAction`, then call a method that implements the actual state mutation.

# Store Subscribers

Store subscribers are types that are interested in receiving state updates from a store. Whenever the store updates its state it will notify all subscribers by calling the `newState` method on them. Subscribers need to conform to the `StoreSubscriber` protocol:

```swift
protocol StoreSubscriber {
    func newState(state: StoreSubscriberStateType)
}
```

Most of your `StoreSubscriber`s will be in the view layer and update their representation whenever they receive a new state.

# Middleware

ReSwift supports middleware in the same way as Redux does, [you can read this great documentation on Redux middleware to get started](http://rackt.org/redux/docs/advanced/Middleware.html). Middleware allows developers to provide extensions that wrap the `dispatch` function.

Let's take a look at a quick example that shows how ReSwift supports Redux style middleware.

The simplest example of a middleware, is one that prints all actions to the console. Here's how you can implement it:

```swift
let loggingMiddleware: Middleware = { dispatch, getState in
    return { next in
        return { action in
            // perform middleware logic
            print(action)

            // call next middleware
            return next(action)
        }
    }
}
```
You can define which middleware you would like to use when creating your store:

```swift
MainStore(reducer: reducer, appState: TestStringAppState(),
                    middleware: [loggingMiddleware, secondMiddleware])
```
The actions will pass through the middleware in the order in which they are arranged in the array passed to the store initializer, however ideally middleware should not make any assumptions about when exactly it is called.
