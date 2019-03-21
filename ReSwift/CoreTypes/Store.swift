//
//  Store.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

/**
 This class is the default implementation of the `Store` protocol. You will use this store in most
 of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */
open class Store<State: StateType>: StoreType {

    typealias SubscriptionType = SubscriptionBox<State>

    // swiftlint:disable todo
    // TODO: Setter should not be public; need way for store enhancers to modify appState anyway
    // swiftlint:enable todo

    /*private (set)*/ public var state: State! {
        didSet {
            subscriptions.forEach {
                if $0.subscriber == nil {
                    subscriptions.remove($0)
                } else {
                    $0.newValues(oldState: oldValue, newState: state)
                }
            }
        }
    }

    public var dispatchFunction: DispatchFunction!

    private var reducer: Reducer<State>

    var subscriptions: Set<SubscriptionType> = []

    private var isDispatching = false

    /// Indicates if new subscriptions attempt to apply `skipRepeats` 
    /// by default.
    fileprivate let subscriptionsAutomaticallySkipRepeats: Bool

    /// Initializes the store with a reducer, an initial state and a list of middleware.
    ///
    /// Middleware is applied in the order in which it is passed into this constructor.
    ///
    /// - parameter reducer: Main reducer that processes incoming actions.
    /// - parameter state: Initial state, if any. Can be `nil` and will be 
    ///   provided by the reducer in that case.
    /// - parameter middleware: Ordered list of action pre-processors, acting 
    ///   before the root reducer.
    /// - parameter automaticallySkipsRepeats: If `true`, the store will attempt 
    ///   to skip idempotent state updates when a subscriber's state type 
    ///   implements `Equatable`. Defaults to `true`.
    public required init(
        reducer: @escaping Reducer<State>,
        state: State?,
        middleware: [Middleware<State>] = [],
        automaticallySkipsRepeats: Bool = true
    ) {
        self.subscriptionsAutomaticallySkipRepeats = automaticallySkipsRepeats
        self.reducer = reducer

        // Wrap the dispatch function with all middlewares
        self.dispatchFunction = middleware
            .reversed()
            .reduce(
                { [unowned self] action in
                    self._defaultDispatch(action: action) },
                { dispatchFunction, middleware in
                    // If the store get's deinitialized before the middleware is complete; drop
                    // the action without dispatching.
                    let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
                    let getState = { [weak self] in self?.state }
                    return middleware(dispatch, getState)(dispatchFunction)
            })

        if let state = state {
            self.state = state
        } else {
            dispatch(ReSwiftInit())
        }
    }

    fileprivate func _subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, originalSubscription: Subscription<State>,
        transformedSubscription: Subscription<SelectedState>?)
        where S.StoreSubscriberStateType == SelectedState
    {
        let subscriptionBox = self.subscriptionBox(
            originalSubscription: originalSubscription,
            transformedSubscription: transformedSubscription,
            subscriber: subscriber
        )

        subscriptions.update(with: subscriptionBox)

        if let state = self.state {
            originalSubscription.newValues(oldState: nil, newState: state)
        }
    }

    open func subscribe<S: StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            _ = subscribe(subscriber, transform: nil)
    }

    open func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    {
        // Create a subscription for the new subscriber.
        let originalSubscription = Subscription<State>()
        // Call the optional transformation closure. This allows callers to modify
        // the subscription, e.g. in order to subselect parts of the store's state.
        let transformedSubscription = transform?(originalSubscription)

        _subscribe(subscriber, originalSubscription: originalSubscription,
                   transformedSubscription: transformedSubscription)
    }

    func subscriptionBox<T>(
        originalSubscription: Subscription<State>,
        transformedSubscription: Subscription<T>?,
        subscriber: AnyStoreSubscriber
        ) -> SubscriptionBox<State> {

        return SubscriptionBox(
            originalSubscription: originalSubscription,
            transformedSubscription: transformedSubscription,
            subscriber: subscriber
        )
    }

    open func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
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

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    open func dispatch(_ actionCreatorProvider: @escaping ActionCreator) {
        if let action = actionCreatorProvider(state, self) {
            dispatch(action)
        }
    }

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    open func dispatch(_ asyncActionCreatorProvider: @escaping AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
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

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    public typealias ActionCreator = (_ state: State, _ store: Store) -> Action?

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    public typealias AsyncActionCreator = (
        _ state: State,
        _ store: Store,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
    ) -> Void
}

// MARK: Skip Repeats for Equatable States

extension Store {
    open func subscribe<SelectedState: Equatable, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<State>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState
    {
        let originalSubscription = Subscription<State>()

        var transformedSubscription = transform?(originalSubscription)
        if subscriptionsAutomaticallySkipRepeats {
            transformedSubscription = transformedSubscription?.skipRepeats()
        }
        _subscribe(subscriber, originalSubscription: originalSubscription,
                   transformedSubscription: transformedSubscription)
    }
}

extension Store where State: Equatable {
    open func subscribe<S: StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            guard subscriptionsAutomaticallySkipRepeats else {
                _ = subscribe(subscriber, transform: nil)
                return
            }
            _ = subscribe(subscriber, transform: { $0.skipRepeats() })
    }
}
