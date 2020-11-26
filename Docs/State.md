The application state is defined in a single data structure which should be a `struct`. This `struct` can have other `struct`s as members, that allows you to add different sub-states as your app grows.

The state `struct` should store your entire application state, that includes the UI state, the navigation state and the state of your model layer.

Here's an example of a state `struct` as defined in the [Counter Example](https://github.com/ReSwift/CounterExample):

```swift
struct AppState: HasNavigationState {
    var counter: Int = 0
    var navigationState = NavigationState()
}
```

If you are including `SwiftRouter` in your project, your app state needs to conform to the `HasNavigationState` protocol. This means you need to add a property called `navigationState` to your state `struct`. This is the sub-state the router will use to store the current route.
