//
//  DynamicClassContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class DynamicClassContextTests: XCTestCase {
    
    func testSimple() {
        do {
            let testObject = TestObject()
            let hookClosure = {} as @convention(block) () -> Void as AnyObject
            let context: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
            XCTAssertTrue(class_getSuperclass(context) == TestObject.self)
            XCTAssertEqual(NSStringFromClass(context), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testWrapAndReleaseHookClosureThenWrapAgain() {
        do {
            let testObject = TestObject()
            try autoreleasepool {
                let hookClosure = {} as @convention(block) () -> Void as AnyObject
                let context: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
                XCTAssertTrue(class_getSuperclass(context) == TestObject.self)
                XCTAssertEqual(NSStringFromClass(context), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
            }
            let hookClosure = {} as @convention(block) () -> Void as AnyObject
            let context2: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
            XCTAssertTrue(class_getSuperclass(context2) == TestObject.self)
            XCTAssertEqual(NSStringFromClass(context2), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
