# Getting Started with ReSwift

ReSwift provides the infrastructure for `Store`s, `Action`s and `Reducer`s to enable a unidirectional data flow as shown below.

![](img/reswift_detail.png)

The following steps will describe how to set up the individual components for your ReSwift app.

# State

The application state is defined in a single data structure which should be a struct. This struct can have other structs as members, that allows you to add different sub-states as your app grows.

The state struct should store your entire application state, that includes the UI state, the navigation state and the state of your model layer.

Here's an example of a state struct as defined in the [Counter Example](https://github.com/ReSwift/CounterExample-Navigation-TimeTravel):

```swift
struct AppState: StateType {
    var counter: Int = 0
    var navigationState = NavigationState()
}
```

There are multiple things to note:

1. Your app state struct needs to conform to the `StateType` protocol, currently this is just a marker protocol.
2. If you are including `ReSwiftRouter` in your project, your app state needs to contain a property of type `NavigationState`. This is the sub-state the router will use to store the current route.

## Derived State

Note that you don't need to store derived state inside of your app state. E.g. instead of storing a `UIImage` you should store a image URL that can be used to fetch the image from a cache or via a download. The app state should store all the information that uniquely identifies the current state and allows it to be reconstructed, but none that can be easily derived.

# Actions

Actions are used to express intended state changes. Actions don't contain functions, instead they provide information about the intended state change, e.g. which user should be deleted.

In your ReSwift app you will define actions for every possible state change that can happen.

Reducers handle these actions and implement state changes based on the information the actions provide.

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

Reducers are the only place in which you should modify application state! Reducers take the current application state and an action and return the new transformed application state. We recommend to provide many small reducers that each handle a subset of your application state.

You can do this implementing a top-level reducer that conforms to the `Reducer` protocol. This reducer will then call individual functions for each different part of the app state.

Here's an example in which we construct a new state, by calling sub-reducers with different sub-states:

```swift
func appReducer(action: Action, state: State?) -> State {
    return State(
      navigationState: navigationReducer(action, state: state?.navigationState),
      authenticationState: authenticationReducer(state?.authenticationState, action: action),
      repositories: repositoriesReducer(state?.repositories, action: action),
      bookmarks: bookmarksReducer(state?.bookmarks, action: action)
   )
}
```
The `Reducer` typealias is a method that takes an `Action` and an `State?` and returns a `State`. Typically reducers will be responsible for initializing the application state. When they receive `nil` as the current state, they should return the initial default value for their portion of the state. In the example above the `appReducer` delegates all calls to other reducer functions. E.g. the `authenticationReducer` is responsible for providing the `authenticationState`.

Here's what the `authenticationReducer` function that is called from the `appReducer` looks like:

```swift
func authenticationReducer(state: AuthenticationState?, action: Action) -> AuthenticationState {
    var state = state ?? initialAuthenticationState()

    switch action {
    case _ as SwiftFlowInit:
        break
    case let action as SetOAuthURL:
        state.oAuthURL = action.oAuthUrl
    case let action as UpdateLoggedInState:
        state.loggedInState = action.loggedInState
    default:
        break
    }

    return state
}
```
You can see that the `authenticationReducer` function is a free function. You can define it with any arbitrary method signature, but we recommend that it matches the `Reducer` typealias (current state and action in, new state out).

This sub-reducer first checks if the state provided is `nil`. If that's the case, it sets the state to the initial default state. Next, the reducer switches over the provided `action` and checks its type. Depending on the type of action, this reducer will updated the state differently. This specific reducer is very simple, each action only triggers a single property of the state to update.

Once the state update is complete, the reducer function returns the new state.

After the `appReducer` has called all of the sub-reducer functions, we have a new application state. `ReSwift` will take care of publishing this new state to all subscribers.

# Store Subscribers

Store subscribers are types that are interested in receiving state updates from a store. Whenever the store updates its state it will notify all subscribers by calling the `newState` method on them. Subscribers need to conform to the `StoreSubscriber` protocol:

```swift
protocol StoreSubscriber {
    func newState(state: StoreSubscriberStateType)
}
```

Most of your `StoreSubscriber`s will be in the view layer and update their representation whenever they receive a new state.

## Example With Filtered Subscriptions

Ideally most of our subscribers should only be interested in a very small portion of the overall app state. `ReSwift` provides a way to subselect the relevant state for a particular subscriber at the point of subscription. Here's an example of subscribing, filtering and unsubscribing as used within a view controller:

```swift
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

	// subscribe when VC appears
   	// we are only interested in repository substate, filter it out of the overall state
    store.subscribe(self) { subcription in
        subcription.select { state in state.repositories }
    }
}

override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    // unsubscribe when VC disappears
    store.unsubscribe(self)
}

// The `state` argument needs to match the selected substate
func newState(state: Response<[Repository]>?) {
    if case let .Success(repositories) = state {
        dataSource?.array = repositories
        tableView.reloadData()
    }
}
```
In the example above we only select a single property from the overall application state: a network `Response` with a list of repositories.

When selecting a substate as part of calling the `subscribe` method, you need to make sure that the argument of the `newState` method has the same type as whatever you return from the state subselection in the `subscribe` method.

When subscribing within a ViewController you will typically update the view from within the `newState` method.

# Beyond the Basics

## Asynchronous Operations

Conceptually asynchronous operations can simply be treated as state updates that occur at a later point in time. Here's a simple example of how to tie an asynchronous network request to `ReSwift` state update:

```swift
func fetchGitHubRepositories(state: State, store: Store<State>) -> Action? {
    guard case let .LoggedIn(configuration) = state.authenticationState.loggedInState  else { return nil }

    Octokit(configuration).repositories { response in
        dispatch_async(dispatch_get_main_queue()) {
            store.dispatch(SetRepostories(repositories: response))
        }
    }

    return nil
}
```

In this example we're using the `Octokit` library to perform a network request that fetches a users repositories. Within the callback block of the method we dispatch a state update that injects the received repositories into the app state. This will trigger all receivers to be informed about the new state.

Note that the callback block from the network request arrives on a background thread, therefore we're using `dispatch_async(dispatch_get_main_queue())` to perform the state update on the main thread. `ReSwift` will call reducers and subscribers on whatever thread you have dispatched an action from. We recommend to always dispatch from the main thread, but `ReSwift` does not enforce this recommendation. ReSwift *will* enforce that all Dispatches, Store Subscribes and Store Unsubscribes are on the same thread or serial Grand Central Dispatch queue. Therefore the main dispatch queue works, however the global dispatch queue, being concurrent, will fail.

In many cases your asynchronous tasks will consist of two separate steps:

1. Update UI to show a loading indicator
2. Refresh the UI once data arrived

You can extend the example above, by dispatching a separate action, as soon as the network request starts. The goal of that action is to trigger the UI to update & show a loading indicator.

```swift
func fetchGitHubRepositories(state: State, store: Store<State>) -> Action? {
    guard case let .LoggedIn(configuration) = state.authenticationState.loggedInState  else { return nil }

    Octokit(configuration).repositories { response in
        dispatch_async(dispatch_get_main_queue()) {
            store.dispatch(SetRepostories(repositories: .Repositories(response)))
        }
    }

    return SetRepositories(repositories: .Loading)
}
```

In the example above, we're using an `enum` to represent the different states of a single state slice that depends on a network request (e.g. loading, result available, network request failed). There are many different ways to model states of a network request but it will mostly involve using multiple dispatched actions at different stages of your network requests.

## Action Creators

An important aspect of adopting `ReSwift` is an improved separation of concerns. Specifically, your view layer should mostly be concerned with adopting its representation to match a new app state and for triggering `Action`s upon user interactions.

The triggering of actions should always be as simple as possible, we want to avoid any sort of complicated business logic in the view. However, in some cases it can be complicated to decide whether an action should be dispatched or not. Instead of checking the necessary state directly in the view or view controller, you can use `ActionCreator`s to perform a conditional dispatch.

Just like an `Action` a `ActionCreator` function can be dispatched to the store. An `ActionCreator` takes the current application state, and a reference to a store and might or might not return an `Action`.

An `ActionCreator` has the following type signature:
```swift
typealias ActionCreator = (state: State, store: StoreType) -> Action?
```

A very simple example of an `ActionCreator` might be:
```swift
func doubleValueIfSmall(state: TestAppState, store: Store<TestAppState>) -> Action? {
	if state.testValue < 5 {
		return SetValueAction(state.testValue! * 2)
	} else {
		return nil
	}
}
```

## Middleware

ReSwift supports middleware in the same way as Redux does, [you can read this great documentation on Redux middleware to get started](http://redux.js.org/docs/advanced/Middleware.html). Middleware allows developers to provide extensions that wrap the `dispatch` function.

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
Store(reducer: reducer, appState: TestStringAppState(),
                    middleware: [loggingMiddleware, secondMiddleware])
```
The actions will pass through the middleware in the order in which they are arranged in the array passed to the store initializer, however ideally middleware should not make any assumptions about when exactly it is called.
