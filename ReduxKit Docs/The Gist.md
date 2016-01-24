## The Gist

A more advanced Swift example of the original [gist](https://github.com/rackt/redux/blob/master/README.md#the-gist)

```swift
import ReduxKit

/**
 This is an extremely simple and flexible action. The only requirement for actions is that they
 conform to the Action protocol.

 The Action protocol can be inherited from for app specific Action requirements. For a good example
 of this, see FluxStandardAction and the implementing types in the source.

 Action can be implemented as an enum, struct or class.
 */
struct IncrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
}

struct DecrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
}

/**
 This is a simple reducer. It is a pure function that follows the syntax (State, Action) -> State.
 It describes how an action transforms the previous state into the next state.

 Instead of using the Action.type property - as is done in the regular Redux framework we use the
 power of Swifts static typing to deduce the action.
 */
func counterReducer(previousState: Int?, action: Action) -> Int {
    // Declare the reducers default value
    let defaultValue = 0
    var state = previousState ?? defaultValue

    switch action {
        case let action as IncrementAction:
            return state + action.payload
        case let action as DecrementAction:
            return state - action.payload
        default:
            return state
    }
}

/**
 The applications state. This should contain the state of the whole application.
 When building larger applications, you can optionally assign complex structs to properties on the
 AppState and handle them in the part of the application that uses them.
 */
struct AppState {
    var count: Int!
}

/**
 Create the applications reducer. While we could create a combineReducer function we've currently
 chosen to allow reducers to be statically typed and accept static states - instead of Any - which
 currently forces us to define the application reducer as such. This could possibly be simplified
 with reflection.
 */
let applicationReducer = {(state: AppState? = nil, action: Action) -> AppState in

    return AppState(
        count: counterReducer(state?.count, action: action),
    )
}

// Create application store. The second parameter is an optional default state.
let store = createStore(applicationReducer, nil)

let disposable = store.subscribe { state in
    print(state)
}


store.dispatch(IncrementAction())
// {counter: 1}

store.dispatch(IncrementAction())
// {counter: 2}

store.dispatch(DecrementAction())
// {counter: 1}

// Dispose of the subscriber after use.
disposable.dispose()

```
