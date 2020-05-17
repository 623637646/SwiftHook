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
    
    func testDeallocForSingle() {
        do {
            var executed = [Int]()
            try autoreleasepool {
                let object = ObjectiveCTestObject()
                let object2 = TestObject()
                
                // Customize API
                try hookBefore(object: object, selector: deallocSelector) {
                    executed.append(1)
                }
                try hookAfter(object: object, selector: deallocSelector) {
                    executed.append(2)
                }
                
                do {
                    try hookBefore(object: TestObject(), selector: deallocSelector) {}
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .hookSwiftObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                do {
                    try hookAfter(object: TestObject(), selector: deallocSelector) {}
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .hookSwiftObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                do {
                    try hookInstead(object: TestObject(), selector: deallocSelector, closure: { original in
                        original()
                        } as @convention(block) (() -> Void) -> Void)
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .hookSwiftObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                do {
                    try hookInstead(object: object, selector: deallocSelector, closure: { original in
                        original()
                        } as @convention(block) (() -> Void) -> Void)
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .insteadHookNSObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                // Public API
                try hookDeallocBefore(object: object, closure: {
                    executed.append(3)
                })
                try hookDeallocAfter(object: object, closure: {
                    executed.append(4)
                })
                try hookDeallocAfter(object: object2, closure: {
                    executed.append(5)
                })
                
                XCTAssertEqual(executed, [])
            }
            XCTAssertEqual(executed, [5, 3, 1, 4, 2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testDeallocForAllInstances() {
        do {
            var executed = [Int]()
            try autoreleasepool {
                let object1 = ObjectiveCTestObject()
                _ = ObjectiveCTestObject() // This will not trigger hook because it will release immediately. Maybe compiler optimization.
                
                // Customize API
                try hookBefore(targetClass: ObjectiveCTestObject.self, selector: deallocSelector) {
                    executed.append(1)
                }
                try hookAfter(targetClass: ObjectiveCTestObject.self, selector: deallocSelector) {
                    executed.append(2)
                }
                
                do {
                    try hookBefore(targetClass: TestObject.self, selector: deallocSelector) {}
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .hookSwiftObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                do {
                    try hookAfter(targetClass: TestObject.self, selector: deallocSelector) {}
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .hookSwiftObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                do {
                    try hookInstead(targetClass: TestObject.self, selector: deallocSelector, closure: { original in
                        original()
                        } as @convention(block) (() -> Void) -> Void)
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .hookSwiftObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                do {
                    try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original in
                        original()
                        } as @convention(block) (() -> Void) -> Void)
                    XCTAssertTrue(false)
                } catch SwiftHookError.unsupport((let type)) {
                    XCTAssertTrue(type == .insteadHookNSObjectDealloc)
                } catch {
                    XCTAssertNil(error)
                }
                
                // Public API
                try hookDeallocBefore(targetClass: ObjectiveCTestObject.self, closure: {
                    executed.append(3)
                })
                try hookDeallocAfter(targetClass: ObjectiveCTestObject.self, closure: {
                    executed.append(4)
                })
                
                XCTAssertEqual(executed, [])
                
                let object2 = ObjectiveCTestObject()
                _ = ObjectiveCTestObject() // This will trigger hook
                _ = [object1, object2]
            }
            XCTAssertEqual(executed, [3, 1, 4, 2, 3, 1, 4, 2, 3, 1, 4, 2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
