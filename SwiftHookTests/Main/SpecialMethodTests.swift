//
//  SpecialMethodTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SpecialMethodTests: XCTestCase {
    
    func testDeallocForSingleOCObject() {
        do {
            var executed = [Int]()
            try autoreleasepool {
                let object = ObjectiveCTestObject()
                object.deallocExecution = {
                    executed.append(0)
                }
                XCTAssertFalse(try testIsDynamicClass(object: object))
                
                // before
                try hookBefore(object: object, selector: deallocSelector) {
                    executed.append(-1)
                }
                try hookDeallocBefore(object: object, closure: {
                    executed.append(-2)
                })
                
                // instead
                try hookInstead(object: object, selector: deallocSelector, closure: { original in
                    executed.append(-3)
                    original()
                    executed.append(3)
                    } as @convention(block) (() -> Void) -> Void)
                try hookDeallocInstead(object: object, closure: { original in
                    executed.append(-4)
                    original()
                    executed.append(4)
                    } as @convention(block) (() -> Void) -> Void)
                
                // after
                try hookAfter(object: object, selector: deallocSelector) {
                    executed.append(1)
                }
                try hookDeallocAfter(object: object, closure: {
                    executed.append(2)
                })
                try hookDeallocAfterByTail(object: object, closure: {
                    executed.append(5)
                })
                XCTAssertTrue(try testIsDynamicClass(object: object))
                
                XCTAssertEqual(executed, [])
            }
            XCTAssertEqual(executed, [-2, -1, -4, -3, 0, 5, 3, 4, 2, 1])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testDeallocForSingleSwiftObject() {
        do {
            var executed = [Int]()
            try autoreleasepool {
                let object = TestObject()
                object.deinitExecution = {
                    executed.append(0)
                }
                
                XCTAssertFalse(try testIsDynamicClass(object: object))
                try hookDeallocAfterByTail(object: object, closure: {
                    executed.append(2)
                })
                XCTAssertFalse(try testIsDynamicClass(object: object))
                
                XCTAssertEqual(executed, [])
            }
            XCTAssertEqual(executed, [0, 2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testDeallocForAllInstancesOCObject() {
        do {
            var executed = [Int]()
            var tokens = [Token]()
            try autoreleasepool {
                let objectBefore = ObjectiveCTestObject()
                objectBefore.deallocExecution = {
                    executed.append(0)
                }
                _ = ObjectiveCTestObject() // This will not trigger hook because it will release immediately. Maybe compiler optimization.
                
                // before
                let token1 = try hookBefore(targetClass: ObjectiveCTestObject.self, selector: deallocSelector) {
                    executed.append(-1)
                }
                tokens.append(token1)
                let token2 = try hookDeallocBefore(targetClass: ObjectiveCTestObject.self, closure: {
                    executed.append(-2)
                })
                tokens.append(token2)
                
                // instead
                let token3 = try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original in
                    executed.append(-3)
                    original()
                    executed.append(3)
                    } as @convention(block) (() -> Void) -> Void)
                tokens.append(token3)
                let token4 = try hookDeallocInstead(targetClass: ObjectiveCTestObject.self, closure: { original in
                    executed.append(-4)
                    original()
                    executed.append(4)
                    } as @convention(block) (() -> Void) -> Void)
                tokens.append(token4)
                
                // after
                let token5 = try hookAfter(targetClass: ObjectiveCTestObject.self, selector: deallocSelector) {
                    executed.append(1)
                }
                tokens.append(token5)
                let token6 = try hookDeallocAfter(targetClass: ObjectiveCTestObject.self, closure: {
                    executed.append(2)
                })
                tokens.append(token6)
                
                let objectAfter = ObjectiveCTestObject()
                objectAfter.deallocExecution = {
                    executed.append(0)
                }
                _ = ObjectiveCTestObject() // This will trigger hook immediately.
                
                XCTAssertEqual(executed, [-2, -1, -4, -3, 3, 4, 2, 1])
                executed.removeAll()
            }
            XCTAssertEqual(executed, [-2, -1, -4, -3, 0, 3, 4, 2, 1, -2, -1, -4, -3, 0, 3, 4, 2, 1])
            tokens.forEach { (token) in
                token.cancelHook()
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
