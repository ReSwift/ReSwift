Store subscribers are types that are interested in receiving state updates from a store. Whenever the store updates its state it will notify all subscribers by calling the `newState` method on them. Subscribers need to conform to the `StoreSubscriber` protocol:

```swift
protocol StoreSubscriber {
    func newState(state: StoreSubscriberStateType)
}
```

Most of your `StoreSubscriber`s will be in the view layer and update their representation whenever they receive a new state.
