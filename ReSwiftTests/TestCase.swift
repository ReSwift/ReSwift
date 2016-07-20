//
//  TestCase.swift
//  ReSwift
//
//  Created by Madhava Jay on 20/07/2016.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation
import XCTest

// -------------------------------------------------------------------------------------------------
// MARK: - Utility Base Class for Unit Tests
// -------------------------------------------------------------------------------------------------
extension XCTestCase {

  func wait(_ seconds: Double, completionHandler: () -> Void) {
    let promise = expectation(description: "wait")

    fakeAsync(seconds) {
      completionHandler()
      promise.fulfill()
    }

    waitForExpectations(timeout: Double(seconds + 1)) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func fakeAsync(_ seconds: Double, completionHandler: () -> Void) {
    let globalQueue = DispatchQueue.global()
    let time = DispatchTime.now() + seconds

    globalQueue.after(when: time) {
      completionHandler()
    }
  }
}
