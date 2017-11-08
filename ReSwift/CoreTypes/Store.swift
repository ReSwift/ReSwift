//
//  Store.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Foundation

/**
 This class is the default implementation of the `Store` protocol. You will use this store in most
 of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */
open class Store<State: StateType>: StoreType {

    typealias StateChangeType = StateChange<State>

    // swiftlint:disable todo
    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway
    // swiftlint:enable todo

    /*private (set)*/ public var state: State! {
        didSet {
//            subscriptions = subscriptions.filter { $0.subscriber != nil }
            stateChangeStreams.forEach { stateChange in
                stateChange.onChange(oldState: oldValue, newState: state)
            }
        }
    }

    public var dispatchFunction: DispatchFunction!

    private var reducer: Reducer<State>

    var stateChangeStreams: [StateChangeType] = []

    private var isDispatching = false

    /// Indicates if new subscriptions attempt to apply `skipRepeats` 
    /// by default.
    internal let subscriptionsAutomaticallySkipEquatable: Bool

    @available(*, deprecated: 1.0, renamed: "init(reducer:state:middleware:automaticallySkipsEquatable:)")
    public convenience init(
        reducer: @escaping Reducer<State>,
        state: State?,
        middleware: [Middleware<State>] = [],
        automaticallySkipsRepeats: Bool
        ) {
        self.init(
            reducer: reducer,
            state: state,
            middleware: middleware,
            automaticallySkipsEquatable: automaticallySkipsRepeats)
    }
    
    /// Initializes the store with a reducer, an initial state and a list of middleware.
    ///
    /// Middleware is applied in the order in which it is passed into this constructor.
    ///
    /// - parameter reducer: Main reducer that processes incomind actions.
    /// - parameter state: Initial state, if any. Can be `nil` and will be 
    ///   provided by the reducer in that case.
    /// - parameter middleware: Ordered list of action pre-processors, acting 
    ///   before the root reducer.
    /// - parameter automaticallySkipsEquatable: If `true`, the store will attempt
    ///   to skip idempotent state updates when a subscriber's state type 
    ///   implements `Equatable`. Defaults to `true`.
    public required init(
        reducer: @escaping Reducer<State>,
        state: State?,
        middleware: [Middleware<State>] = [],
        automaticallySkipsEquatable: Bool = true
    ) {
        self.subscriptionsAutomaticallySkipEquatable = automaticallySkipsEquatable
        self.reducer = reducer

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce({ [unowned self] action in
                self._defaultDispatch(action: action)
            }) { dispatchFunction, middleware in
                // If the store get's deinitialized before the middleware is complete; drop
                // the action without dispatching.
                let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
                let getState = { [weak self] in self?.state }
                return middleware(dispatch, getState)(dispatchFunction)
        }

        if let state = state {
            self.state = state
        } else {
            dispatch(ReSwiftInit())
        }
    }

    open func stateChange() -> StateChange<State> {
        let stateChangeStream = StateChange<State>(
            getState: { [weak self] in self?.state },
            automaticallySkipsEquatable: self.subscriptionsAutomaticallySkipEquatable
        )
        self.stateChangeStreams.append(stateChangeStream)
        return stateChangeStream
    }

    @available(*, deprecated: 1.0, renamed: "stateChange()")
    open func subscription() -> StateChange<State> {
        let subscription = StateChange<State>(
            getState: { [weak self] in self?.state },
            automaticallySkipsEquatable: self.subscriptionsAutomaticallySkipEquatable
        )
        self.stateChangeStreams.append(subscription)
        return subscription
    }

    open func unsubscribe(_ subscriber: AnyStoreSubscriber) {
//        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
//            subscriptions.remove(at: index)
//        }
    }

    // swiftlint:disable:next identifier_name
    open func _defaultDispatch(action: Action) {
        guard !isDispatching else {
            raiseFatalError(
                "ReSwift:ConcurrentMutationError- Action has been dispatched while" +
                " a previous action is action is being processed. A reducer" +
                " is dispatching an action, or ReSwift is used in a concurrent context" +
                " (e.g. from multiple threads)."
            )
        }

        isDispatching = true
        let newState = reducer(action, state)
        isDispatching = false

        state = newState
    }

    open func dispatch(_ action: Action) {
        dispatchFunction(action)
    }

    open func dispatch(_ actionCreatorProvider: @escaping ActionCreator) {
        if let action = actionCreatorProvider(state, self) {
            dispatch(action)
        }
    }

    open func dispatch(_ asyncActionCreatorProvider: @escaping AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    open func dispatch(_ actionCreatorProvider: @escaping AsyncActionCreator,
                       callback: DispatchCallback?) {
        actionCreatorProvider(state, self) { actionProvider in
            let action = actionProvider(self.state, self)

            if let action = action {
                self.dispatch(action)
                callback?(self.state)
            }
        }
    }

    public typealias DispatchCallback = (State) -> Void

    public typealias ActionCreator = (_ state: State, _ store: Store) -> Action?

    public typealias AsyncActionCreator = (
        _ state: State,
        _ store: Store,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
    ) -> Void
}
