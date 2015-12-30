//
//  Action.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public struct StandardAction: Action {
    public let type: String
    public let payload: [String: AnyObject]?
    /// Indicates whether this action will be deserialized as a typed action or as a standard action
    public let isTypedAction: Bool

    public init(_ type: String) {
        self.type = type
        self.payload = nil
        self.isTypedAction = false
    }

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

public protocol StandardActionConvertible: Action {
    init (_ standardAction: StandardAction)
    func toStandardAction() -> StandardAction
}

public protocol Action { }
