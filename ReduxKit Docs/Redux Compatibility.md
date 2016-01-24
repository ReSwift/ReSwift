# Redux Compatibility

In general the ReduxKit implementation tries to stay as close as possible to Redux. The main differences appear because Swift is a strongly typed language. With generics support in Swift 2, the implementation is a lot more flexible, but method signatures can become quite complex.

Only an overview of method signature differences are documented here. Arguments, return types and examples are documented in the relevant api sections.

## `applyMiddleware(...middlewares)`

`applyMiddleware` is identical in usage.

> **Swift signature**

```swift
// Swift: ReduxKit
public func applyMiddleware<State>(middleware: [MiddlewareApi<State> -> DispatchTransformer])
    -> (((State?, Action) -> State, State?) -> Store<State>)
    -> (((State?, Action) -> State, State?) -> Store<State>) {
    
// Simplified strongly typed example
func applyMiddleware(middleware: [Middleware]) -> StoreEnhancer
```

See: [Middleware](Middleware.html)

## `bindActionCreators(actionCreators, dispatch)`

`bindActionCreators` is similar in usage to Redux, except `bindActionCreators` takes an Action type and returns a function that accepts a payload to create the action with and passes it to the dispatch method.

Passing in functions and objects are not supported by ReduxKit as their usage is not applicable in Swift.

> **Swift signature**

```swift
public func bindActionCreators<Action where Action: StandardAction>(
    type: Action.Type,
    dispatch: Dispatch)
    -> (payload: Action.PayloadType?)
    -> ()
```


## `combineReducers(reducers)`

`combineReducers` is not implemented in ReduxKit as it's not supported by Swift's runtime introspection and state is strongly typed. In general `combineReducers` is not needed, even in complex applications.

## `compose(...functions)`

Although `compose` is a general function, it is included in ReduxKit for the same reasons as in Redux.

> **Swift signature**

```swift
public func compose<T>(objects: [(T) -> T]) -> (T) -> T
```

## `createStore(reducer, [initialState])`

`createStore` is identical in usage to Redux. It returns a concrete type of Store. The `createStore` function is easily replaced or enhanced.

> **Swift signature**

```swift
public func createStore<State>(
	reducer: (State?, Action) -> State,
	state: State?)
	-> Store<State>

// Strongly typed example
func createStore(reducer: Reducer, state: State?) -> Store
```

## `Store`

The `Store` is implemented as a concrete struct in Swift and allow for a generic State type to be used. The only method not available at the moment is `replaceReducer`.

> **Swift types**

```swift
public protocol StoreType {
	typealias State
    var dispatch: Dispatch { get }
    var subscribe: (State -> ()) -> ReduxDisposable { get }
    var getState: () -> State { get }
    init(dispatch: Dispatch, subscribe: (State -> ()) -> ReduxDisposable, getState: () -> State)
}

public struct Store<State>: StoreType
```
