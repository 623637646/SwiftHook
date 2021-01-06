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
                XCTAssertTrue(try testGetObjectType(object: object) == .normal)
                
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
                XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
                
                XCTAssertEqual(executed, [])
            }
            XCTAssertEqual(executed, [-4, -3, -2, -1, 0, 5, 2, 1, 3, 4])
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
                
                XCTAssertTrue(try testGetObjectType(object: object) == .normal)
                try hookDeallocAfterByTail(object: object, closure: {
                    executed.append(2)
                })
                XCTAssertTrue(try testGetObjectType(object: object) == .normal)
                
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
                
                XCTAssertEqual(executed, [-4, -3, -2, -1, 2, 1, 3, 4])
                executed.removeAll()
            }
            XCTAssertEqual(executed, [-4, -3, -2, -1, 0, 2, 1, 3, 4, -4, -3, -2, -1, 0, 2, 1, 3, 4])
            for (index, token) in tokens.enumerated() {
                guard let hookToken = token as? HookToken else {
                    XCTFail()
                    return
                }
                if index == tokens.count - 1 {
                    XCTAssertTrue(try internalCancelHook(token: hookToken)!)
                } else {
                    XCTAssertFalse(try internalCancelHook(token: hookToken)!)
                }
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Dealloc_And_Capture() {
        do {
            var i = 0
            var token1: Token?
            var token2: Token?
            try autoreleasepool {
                let object = ObjectiveCTestObject()
                
                token1 = try hookDeallocBefore(targetClass: ObjectiveCTestObject.self) { [weak object] in
                    XCTAssertEqual(i, 1)
                    XCTAssertNil(object)
                    i += 1
                }
                
                token2 = try hookDeallocBefore(object: object) {[weak object] in
                    XCTAssertEqual(i, 0)
                    XCTAssertNil(object)
                    i += 1
                }
            }
            token1!.cancelHook()
            token2!.cancelHook()
            XCTAssertEqual(i, 2)
        } catch {
            XCTFail()
        }
    }
    
}
