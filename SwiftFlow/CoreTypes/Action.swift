//
//  Action.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import Foundation

public struct Action: ActionType {
    public let type: String
    public let payload: [String: AnyObject]?

    public init(_ type: String) {
        self.type = type
        self.payload = nil
    }

    public init(type: String, payload: [String: AnyObject]) {
        self.type = type
        self.payload = payload
    }

    public init(type: String, payload payloadConvertible: PayloadConvertible) {
        self.type = type
        self.payload = payloadConvertible.toPayload()
    }

    public func toAction() -> Action {
        return self
    }

}

extension Action: Coding {

    public init(dictionary: [String : AnyObject]) {
        self.type = dictionary["type"] as! String
        self.payload = dictionary["payload"] as? [String: AnyObject]
    }

    public func dictionaryRepresentation() -> [String : AnyObject] {
        if let payload = payload {
            return ["type": type, "payload": payload]
        } else {
            return ["type": type, "payload": "null"]
        }
    }
    
}

public protocol PayloadConvertible {
    func toPayload() -> [String: AnyObject]
}

public protocol ActionConvertible: ActionType {
    init (_ action: Action)
}

public protocol ActionType {
    func toAction() -> Action
}
