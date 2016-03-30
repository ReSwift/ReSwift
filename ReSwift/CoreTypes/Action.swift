//
//  Action.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation
/**
 This is ReSwift's built in action type, it is the only built in type that conforms to the
 `Action` protocol. `StandardAction` can be serialized and can therefore be used with developer
 tools that restore state between app launches.

 The downside of `StandardAction` is that it carries its payload as an untyped dictionary which does
 not play well with Swift's type system.

 It is recommended that you define your own types that conform to `Action` - if you want to be able
 to serialize your custom action types, you can implement `StandardActionConvertible` which will
 make it possible to generate a `StandardAction` from your typed action - the best of both worlds!
*/
public struct StandardAction: Action {
    /// A String that identifies the type of this `StandardAction`
    public let type: String
    /// An untyped, JSON-compatible payload
    public let payload: [String: AnyObject]?
    /// Indicates whether this action will be deserialized as a typed action or as a standard action
    public let isTypedAction: Bool

    /// Initializes this `StandardAction` with only a type. The payload will be nil and
    /// `isTypedAction` will be set to false.
    public init(_ type: String) {
        self.type = type
        self.payload = nil
        self.isTypedAction = false
    }

    /**
     Initializes this `StandardAction` with a type, a payload and information about whether this is
     a typed action or not.

     - parameter type:          String representation of the Action type
     - parameter payload:       Payload convertable to JSON
     - parameter isTypedAction: Is Action a subclassed type
     */
    public init(type: String, payload: [String: AnyObject]?, isTypedAction: Bool = false) {
        self.type = type
        self.payload = payload
        self.isTypedAction = isTypedAction
    }
}

// MARK: Coding Extension

extension StandardAction: Coding {

    public init(dictionary: [String : AnyObject]) {
        self.type = dictionary["type"] as! String
        self.payload = dictionary["payload"] as? [String: AnyObject]
        self.isTypedAction = (dictionary["isTypedAction"] as! Int) == 1 ? true : false
    }

    public func dictionaryRepresentation() -> [String : AnyObject] {
        let payload: AnyObject = self.payload ?? "null"

        return ["type": type, "payload": payload, "isTypedAction": isTypedAction ? 1 : 0]
    }
}

/// Implement this protocol on your custom `Action` type if you want to make the action
/// serializable.
/// - Note: We are working on a tool to automatically generate the implementation of this protocol
///     for your custom action types.
public protocol StandardActionConvertible: Action {
    /**
     Within this initializer you need to use the payload from the `StandardAction` to configure the
     state of your custom action type.

     Example:

     ```
     init(_ standardAction: StandardAction) {
        self.twitterUser = decode(standardAction.payload!["twitterUser"]!)
     }
     ```

    - Note: If you, as most developers, only use action serialization/deserialization during
     development, you can feel free to use the unsafe `!` operator.
    */
    init (_ standardAction: StandardAction)

    /**
     Use the information from your custom action to generate a `StandardAction`. The `type` of the
     StandardAction should typically match the type name of your custom action type. You also need
     to set `isTypedAction` to `true`. Use the information from your action's properties to
     configure the payload of the `StandardAction`.

     Example:

     ```
     func toStandardAction() -> StandardAction {
        let payload = ["twitterUser": encode(self.twitterUser)]

        return StandardAction(type: SearchTwitterScene.SetSelectedTwitterUser.type,
            payload: payload, isTypedAction: true)
     }
     ```

    */
    func toStandardAction() -> StandardAction
}

/// All actions that want to be able to be dispatched to a store need to conform to this protocol
/// Currently it is just a marker protocol with no requirements.
public protocol Action { }

/// Initial Action that is dispatched as soon as the store is created.
/// Reducers respond to this action by configuring their intial state.
public struct ReSwiftInit: Action {}
