//
//  StandardActionTests.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/29/15.
//  Copyright © 2015 Benjamin Encz. All rights reserved.
//

import XCTest
import ReSwift

class StandardActionInitTests: XCTestCase {

    /**
     it can be initialized with just a type
     */
    func testInitWithType() {
        let action = StandardAction(type: "Test")

        XCTAssertEqual(action.type, "Test")
    }

    /**
     it can be initialized with a type and a payload
     */
    func testInitWithTypeAndPayload() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5 as AnyObject])

        let payload = action.payload!["testKey"]! as! Int

        XCTAssertEqual(payload, 5)
        XCTAssertEqual(action.type, "Test")
    }

}

class StandardActionInitSerializationTests: XCTestCase {

    /**
     it can initialize action with a dictionary
     */
    func testCanInitWithDictionary() {
        let actionDictionary: [String: AnyObject] = [
            "type": "TestType" as AnyObject,
            "payload": "ReSwift_Null" as AnyObject,
            "isTypedAction": true as AnyObject
        ]

        let action = StandardAction(dictionary: actionDictionary)

        XCTAssertEqual(action?.type, "TestType")
        XCTAssertNil(action?.payload)
        XCTAssertEqual(action?.isTypedAction, true)
    }

    /**
     it can convert an action to a dictionary
     */
    func testConvertActionToDict() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5 as AnyObject],
            isTypedAction: true)

        let dictionary = action.dictionaryRepresentation

        let type = dictionary["type"] as! String
        let payload = dictionary["payload"] as! [String: AnyObject]
        let isTypedAction = dictionary["isTypedAction"] as! Bool

        XCTAssertEqual(type, "Test")
        XCTAssertEqual(payload["testKey"] as? Int, 5)
        XCTAssertEqual(isTypedAction, true)
    }

    /**
     it can serialize / deserialize actions with payload and without custom type
     */
    func testWithPayloadWithoutCustomType() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5 as AnyObject])
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        let payload = deserializedAction?.payload?["testKey"] as? Int

        XCTAssertEqual(payload, 5)
        XCTAssertEqual(deserializedAction?.type, "Test")
    }

    /**
     it can serialize / deserialize actions with payload and with custom type
     */
    func testWithPayloadAndCustomType() {
        let action = StandardAction(type:"Test", payload: ["testKey": 5 as AnyObject],
                        isTypedAction: true)
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        let payload = deserializedAction?.payload?["testKey"] as? Int

        XCTAssertEqual(payload, 5)
        XCTAssertEqual(deserializedAction?.type, "Test")
        XCTAssertEqual(deserializedAction?.isTypedAction, true)
    }

    /**
     it can serialize / deserialize actions without payload and without custom type
     */
    func testWithoutPayloadOrCustomType() {
        let action = StandardAction(type:"Test", payload: nil)
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        XCTAssertNil(deserializedAction?.payload)
        XCTAssertEqual(deserializedAction?.type, "Test")
    }

    /**
     it can serialize / deserialize actions without payload and with custom type
     */
    func testWithoutPayloadWithCustomType() {
        let action = StandardAction(type:"Test", payload: nil,
            isTypedAction: true)
        let dictionary = action.dictionaryRepresentation

        let deserializedAction = StandardAction(dictionary: dictionary)

        XCTAssertNil(deserializedAction?.payload)
        XCTAssertEqual(deserializedAction?.type, "Test")
        XCTAssertEqual(deserializedAction?.isTypedAction, true)
    }

    /**
     it initializer returns nil when invalid dictionary is passed in
     */
    func testReturnsNilWhenInvalid() {
        let deserializedAction = StandardAction(dictionary: [:])

        XCTAssertNil(deserializedAction)
    }
}

class StandardActionConvertibleInit: XCTestCase {

    /**
     it initializer returns nil when invalid dictionary is passed in
     */
    func testInitWithStandardAction() {
        let standardAction = StandardAction(type: "Test", payload: ["value": 10 as AnyObject])
        let action = SetValueAction(standardAction)

        XCTAssertEqual(action.value, 10)
    }

    func testInitWithStringStandardAction() {
        let standardAction = StandardAction(type: "Test", payload: ["value": "10" as AnyObject])
        let action = SetValueStringAction(standardAction)

        XCTAssertEqual(action.value, "10")
    }

}

class StandardActionConvertibleTests: XCTestCase {

    /**
     it can be converted to a standard action
     */
    func testConvertToStandardAction() {
        let action = SetValueAction(5)

        let standardAction = action.toStandardAction()

        XCTAssertEqual(standardAction.type, "SetValueAction")
        XCTAssertEqual(standardAction.isTypedAction, true)
        XCTAssertEqual(standardAction.payload?["value"] as? Int, 5)
    }

    func testConvertToStringStandardAction() {
        let action = SetValueStringAction("5")

        let standardAction = action.toStandardAction()

        XCTAssertEqual(standardAction.type, "SetValueStringAction")
        XCTAssertEqual(standardAction.isTypedAction, true)
        XCTAssertEqual(standardAction.payload?["value"] as? String, "5")
    }
}
