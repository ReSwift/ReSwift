## Types and the generic State

ReduxKit makes heavy use of Swift generics for simpler implementation and usage.

The only types used as generics are `State`, `Action` and `PayloadType`. Of which only `State` has no inference and will be commonly used. Because `typealias` does not support generics this does cause the framework source to become harder to read. Example `typealias` have been included privately in the source.

Once the root state type has been defined in your project, you may want to declare appropriate `typealias` mapping to the JavaScript Redux types.

```swift
// These two are already exported by ReduxKit as they do not use the State generic
// typealias Dispatch = Action -> Action
// typealias DispatchTransformer = Dispatch -> Dispatch

struct State {} // Can be named anything you like, as long as it's consistent in the typealias declarations

// Underscores are used where needed to prevent clashes with exported protocols. Again, naming is up to you.

typealias Store = ReduxKit.Store<State>

typealias Reducer = (previousState: State?, action: Action) -> State
typealias Subscriber = (updatedState: State) -> ()

typealias MiddlewareApi = Store
typealias Middleware = MiddlewareApi -> DispatchTransformer
typealias StoreCreator = (reducer: Reducer, initialState: State?) -> Store
typealias StoreEnhancer = (StoreCreator) -> StoreCreator
```

Typealias not supporting generics can been seen most in the applyMiddleware function and makes for the best example of how to expand the ReduxKit examples out.

```swift
// How the applyMiddleware function would ideally be declared
func applyMiddleware(middleware: [Middleware])
	-> StoreEnhancer

// Expanding out (sans generic state):
func applyMiddleware(middleware: [MiddlewareApi -> DispatchTransformer])
	-> StoreCreator
	-> StoreCreator

func applyMiddleware(middleware: [Store -> DispatchTransformer])
	-> ((Reducer, State?) -> Store)
	-> ((Reducer, State?) -> Store)

func applyMiddleware(middleware: [Store -> DispatchTransformer])
	-> (((State?, Action) -> State, State?) -> Store)
	-> (((State?, Action) -> State, State?) -> Store)

// With the generic State
func applyMiddleware<State>(middleware: [(Store<State>) -> DispatchTransformer])
	-> (((State?, Action) -> State, State?) -> Store<State>)
	-> (((State?, Action) -> State, State?) -> Store<State>)
```
