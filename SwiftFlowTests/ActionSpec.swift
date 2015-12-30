//
//  ActionSpec.swift
//  SwiftFlow
//
//  Created by Benjamin Encz on 12/29/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SwiftFlow

// swiftlint:disable function_body_length
class ActionSpec: QuickSpec {

    override func spec() {
        describe("StandardAction") {

            context("#init") {

                it("can be initialized with just a type") {
                    let action = StandardAction("Test")

                    expect(action.type).to(equal("Test"))
                }

                it("can be initialized with a type and a payload") {
                    let action = StandardAction(type:"Test", payload: ["testKey": 5])

                    let payload = action.payload!["testKey"]! as! Int

                    expect(payload).to(equal(5))
                    expect(action.type).to(equal("Test"))
                }

            }

            context("#init-serialization") {

                it("can initialize action with a dictionary") {
                    let actionDictionary = [
                        "type": "TestType",
                        "payload": "null",
                        "isTypedAction": 1
                    ]

                    let action = StandardAction(dictionary: actionDictionary)

                    expect(action.type).to(equal("TestType"))
                    expect(action.payload).to(beNil())
                    expect(action.isTypedAction).to(equal(true))
                }

                it("can convert an action to a dictionary") {
                    let action = StandardAction(type:"Test", payload: ["testKey": 5],
                        isTypedAction: true)

                    let dictionary = action.dictionaryRepresentation()

                    let type = dictionary["type"] as! String
                    let payload = dictionary["payload"] as! [String: AnyObject]
                    let isTypedAction = dictionary["isTypedAction"] as! Int

                    expect(type).to(equal("Test"))
                    expect(payload["testKey"] as? Int).to(equal(5))
                    expect(isTypedAction).to(equal(1))
                }

                it("can serialize / deserialize actions with payload and without custom type") {
                    let action = StandardAction(type:"Test", payload: ["testKey": 5])
                    let dictionary = action.dictionaryRepresentation()

                    let deserializedAction = StandardAction(dictionary: dictionary)

                    let payload = deserializedAction.payload!["testKey"]! as! Int

                    expect(payload).to(equal(5))
                    expect(deserializedAction.type).to(equal("Test"))
                }

                it("can serialize / deserialize actions with payload and with custom type") {
                    let action = StandardAction(type:"Test", payload: ["testKey": 5],
                                    isTypedAction: true)
                    let dictionary = action.dictionaryRepresentation()

                    let deserializedAction = StandardAction(dictionary: dictionary)

                    let payload = deserializedAction.payload!["testKey"]! as! Int

                    expect(payload).to(equal(5))
                    expect(deserializedAction.type).to(equal("Test"))
                    expect(deserializedAction.isTypedAction).to(equal(true))
                }

                it("can serialize / deserialize actions without payload and without custom type") {
                    let action = StandardAction(type:"Test", payload: nil)
                    let dictionary = action.dictionaryRepresentation()

                    let deserializedAction = StandardAction(dictionary: dictionary)

                    expect(deserializedAction.payload).to(beNil())
                    expect(deserializedAction.type).to(equal("Test"))
                }

                it("can serialize / deserialize actions without payload and with custom type") {
                    let action = StandardAction(type:"Test", payload: nil,
                        isTypedAction: true)
                    let dictionary = action.dictionaryRepresentation()

                    let deserializedAction = StandardAction(dictionary: dictionary)

                    expect(deserializedAction.payload).to(beNil())
                    expect(deserializedAction.type).to(equal("Test"))
                    expect(deserializedAction.isTypedAction).to(equal(true))
                }
            }
        }

        describe("StandardActionConvertible") {

            context("#init") {

                it("can be initialized with a standard action") {
                    let standardAction = StandardAction(type: "Test", payload: ["value": 10])
                    let action = SetValueAction(standardAction)

                    expect(action.value).to(equal(10))
                }

            }

            context("#toStandardAction") {

                it("can be converted to a standard action") {
                    let action = SetValueAction(5)

                    let standardAction = action.toStandardAction()

                    expect(standardAction.type).to(equal("SetValueAction"))
                    expect(standardAction.isTypedAction).to(equal(true))
                    expect(standardAction.payload?["value"] as? Int).to(equal(5))
                }

            }

        }
    }

}
// swiftlint:enable function_body_length
