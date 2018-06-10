//
//  Action.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

/// All actions that want to be able to be dispatched to a store need to conform to this protocol
/// Currently it is just a marker protocol with no requirements.
public protocol Action { }

/// Initial Action that is dispatched as soon as the store is created.
/// Reducers respond to this action by configuring their initial state.
public struct ReSwiftInit: Action {}
