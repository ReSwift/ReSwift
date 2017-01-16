//
//  SubscriberWrapper.swift
//  ReSwift
//
//  Created by Virgilio Favero Neto on 4/02/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

protocol AnySubscription {
    var subscriber: AnyStoreSubscriber? { get }
    func newState<T: StateType>(state: T, oldState: T?)
}

struct Subscription<State: StateType, SelectedState> {
    private(set) weak var subscriber: AnyStoreSubscriber? = nil
    let selector: ((State) -> SelectedState)?

    func newState(state: State, oldState: State?) {
        if let selector = selector {
            subscriber?._newState(state: selector(state), oldState: oldState.map(selector))
        } else if let state = state as? SelectedState {
            subscriber?._newState(state: state, oldState: oldState as? SelectedState)
        }
    }
}

struct EquatableSubscription<State: StateType, SelectedState: EquatableState> {
    private(set) weak var subscriber: AnyStoreSubscriber? = nil
    let selector: ((State) -> SelectedState)?

    func newState(state: State, oldState: State?) {
        if let selector = selector {
            subscriber?._newEquatableState(state: selector(state), oldState: oldState.map(selector))
        } else if let state = state as? SelectedState {
            subscriber?._newEquatableState(state: state, oldState: oldState as? SelectedState)
        }
    }
}

struct OptionalEquatableSubscription<State: StateType, SelectedState: EquatableState> {
    private(set) weak var subscriber: AnyStoreSubscriber? = nil
    let selector: ((State) -> SelectedState?)?

    func newState(state: State, oldState: State?) {
        if let selector = selector {
            subscriber?._newOptionalEquatableState(
                state: selector(state),
                oldState: oldState.map(selector)
            )
        } else {
            fatalError("Impossible to have optional base state")
        }
    }
}

extension Subscription: AnySubscription {
    func newState<T: StateType>(state: T, oldState: T?) {
        if let state = state as? State {
            let oldState = oldState as? State
            newState(state: state, oldState: oldState)
        }
    }
}

extension EquatableSubscription: AnySubscription {
    func newState<T: StateType>(state: T, oldState: T?) {
        if let state = state as? State {
            let oldState = oldState as? State
            newState(state: state, oldState: oldState)
        }
    }
}

extension OptionalEquatableSubscription: AnySubscription {
    func newState<T: StateType>(state: T, oldState: T?) {
        if let state = state as? State {
            let oldState = oldState as? State
            newState(state: state, oldState: oldState)
        }
    }
}
