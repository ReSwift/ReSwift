//
//  ActionSpec.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/29/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
@testable import ReSwift

// swiftlint:disable function_body_length
class ActionSpec: XCTest {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // StandardAction
    // #init
    func testCanBeInitWithJustType() {
    // can be initialized with just a type
        let action = StandardAction(type: "Test")

        XCTAssertEqual(action.type, "Test")
    }

    // can be initialized with a type and a payload
    func testCanBeInitWithTypeAndPayload() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5])

        let payload = action.payload!["testKey"]! as! Int

        XCTAssertEqual(payload, 5)
        XCTAssertEqual(action.type, "Test")
    }

    // #init-serialization
    // can initialize action with a dictionary
    func testInitActionWithDict() {
        let actionDictionary: [String: AnyObject?] = [
            "type": "TestType",
            "payload": nil,
            "isTypedAction": true
        ]

        let action = StandardAction(dictionary: actionDictionary)

        XCTAssertEqual(action.type, "TestType")
        XCTAssertNil(action?.payload)
        XCTAssertTrue(action?.isTypedAction)
    }

    // can convert an action to a dictionary
    func testCanConvertActionToDict() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5],
            isTypedAction: true)

        let dictionary = action.dictionaryRepresentation

        let type = dictionary["type"] as! String
        let payload = dictionary["payload"] as! [String: AnyObject]
        let isTypedAction = dictionary["isTypedAction"] as! Int

        XCTAssertEqual(type, "Test")
        XCTAssertEqual(payload["testKey"] as? Int, 5)
        XCTAssertEqual(isTypedAction, 1)
    }

    // can serialize / deserialize actions with payload and without custom type
    func testCanSerializeDeserializeActionsWithPayloadNoCustomType() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5])
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        let payload = deserializedAction?.payload?["testKey"] as? Int

        XCTAssertEqual(payload, 5)
        XCTAssertEqual(deserializedAction?.type, "Test")
    }

    // can serialize / deserialize actions with payload and with custom type
    func testCanSerializeDeserializeActionsWithPayloadWithCustomType() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5],
                        isTypedAction: true)
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        let payload = deserializedAction?.payload?["testKey"] as? Int

        XCTAssertEqual(payload, 5)
        XCTAssertEqual(deserializedAction?.type, "Test")
        XCTAssertTrue(deserializedAction?.isTypedAction)
    }

    // can serialize / deserialize actions without payload and without custom type
    func testCanSerializeDeserializeActionsWithoutPayloadNoCustomType() {
        let action = StandardAction(type:"Test", payload: nil)
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        expect(deserializedAction?.payload).to(beNil())
        expect(deserializedAction?.type).to(equal("Test"))

        XCTAssertNil(deserializedAction?.payload)
        XCTAssertEqual(deserializedAction?.type, "Test")
    }

    // can serialize / deserialize actions without payload and with custom type
    func testCanSerializeDeserializeActionsWithoutPayloadWithCustomType() {
        let action = StandardAction(type:"Test", payload: nil,
            isTypedAction: true)
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        XCTAssertNil(deserializedAction?.payload)
        XCTAssertEqual(deserializedAction?.type, "Test")
        XCTAssertTrue(deserializedAction?.isTypedAction)
    }

    // initializer returns nil when invalid dictionary is passed in
    func testInitReturnsNilWithInvalidDict() {
        let deserializedAction = StandardAction(dictionary: [:])

        XCTAssertNil(deserializedAction)
    }

    // StandardActionConvertible
    // #init
    // can be initialized with a standard action
    func testCanBeInitWithStandardAction() {
        let standardAction = StandardAction(type: "Test", payload: ["value": 10])
        let action = SetValueAction(standardAction)

        XCTAssertEqual(action.value, 10)
    }

    // #toStandardAction
    // can be converted to a standard action
    func testCanBeConvertedToStandardAction() {
        let action = SetValueAction(5)

        let standardAction = action.toStandardAction()

        XCTAssertEqual(standardAction.type, "SetValueAction")
        XCTAssertTrue(standardAction.isTypedAction)
        XCTAssertEqual(standardAction.payload?["value"] as? Int, 5)
    }
}
// swiftlint:enable function_body_length
