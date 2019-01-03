import Foundation

/**
 Defines the interface of a dispatching, stateless Store in ReSwift. `StoreType` is
 the default usage of this interface. Can be used for store variables where you don't
 care about the state, but want to be able to dispatch actions.
 */
public protocol DispatchingStoreType {

    /**
     Dispatches an action. This is the simplest way to modify the stores state.

     Example of dispatching an action:

     ```
     store.dispatch( CounterAction.IncreaseCounter )
     ```

     - parameter action: The action that is being dispatched to the store
     */
    func dispatch(_ action: Action)
}
