//
//  SpecialMethodTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

// TODO: Unfinish
class SpecialMethodTests: XCTestCase {
    
    func testNSObjectDeallocForSingle() {
        do {
            var executed = [Int]()
            try autoreleasepool {
                let object = ObjectiveCTestObject()
                let selector = NSSelectorFromString("dealloc")
                try hookBefore(object: object, selector: selector) {
                    executed.append(1)
                }
                try hookAfter(object: object, selector: selector) {
                    executed.append(2)
                }
                XCTAssertEqual(executed, [])
            }
            XCTAssertEqual(executed, [1, 2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNSObjectDeallocForAllInstances() {
        do {
            var executed = [Int]()
            try autoreleasepool {
                let object1 = ObjectiveCTestObject()
                _ = ObjectiveCTestObject() // This will not trigger hook because it will release immediately. Maybe compiler optimization.
                
                let selector = NSSelectorFromString("dealloc")
                try hookBefore(targetClass: ObjectiveCTestObject.self, selector: selector) {
                    executed.append(1)
                }
                try hookAfter(targetClass: ObjectiveCTestObject.self, selector: selector) {
                    executed.append(2)
                }
                XCTAssertEqual(executed, [])
                
                let object2 = ObjectiveCTestObject()
                _ = ObjectiveCTestObject() // This will not trigger
                _ = [object1, object2]
            }
            XCTAssertEqual(executed, [1, 2, 1, 2, 1, 2])
        } catch {
            XCTAssertNil(error)
        }
    }
}
