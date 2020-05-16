//
//  DynamicClassContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

// TODO: 做到这里了，完善 DynamicClassContextTests
class DynamicClassContextTests: XCTestCase {
    
    func testNormal() {
        do {
            let testObject = TestObject()
            XCTAssertFalse(try isDynamicClass(object: testObject))
            
            let hookClosure = {} as @convention(block) () -> Void as AnyObject
            XCTAssertNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            
            let context: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
            
            XCTAssertTrue(try isDynamicClass(object: testObject))
            XCTAssertNotNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            XCTAssertTrue(debugGetDynamicClassContextAsAnyObject(object: testObject) === debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            XCTAssertTrue(class_getSuperclass(context) == TestObject.self)
            XCTAssertEqual(NSStringFromClass(context), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testReuseContext() {
        do {
            let testObject = TestObject()
            XCTAssertFalse(try isDynamicClass(object: testObject))
            
            // 1
            let hookClosure = {} as @convention(block) () -> Void as AnyObject
            XCTAssertNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            
            let context: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
            
            XCTAssertTrue(try isDynamicClass(object: testObject))
            XCTAssertNotNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            XCTAssertTrue(debugGetDynamicClassContextAsAnyObject(object: testObject) === debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            XCTAssertTrue(class_getSuperclass(context) == TestObject.self)
            XCTAssertEqual(NSStringFromClass(context), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
            
            // 2
            let hookClosure2 = {} as @convention(block) () -> Void as AnyObject
            XCTAssertNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure2))
            
            let context2: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure2)
            
            XCTAssertTrue(try isDynamicClass(object: testObject))
            XCTAssertNotNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure2))
            XCTAssertTrue(debugGetDynamicClassContextAsAnyObject(object: testObject) === debugGetDynamicClassContextAsAnyObject(closure: hookClosure2))
            XCTAssertTrue(class_getSuperclass(context2) == TestObject.self)
            XCTAssertEqual(NSStringFromClass(context2), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
            
            XCTAssertTrue(context == context2)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testReleaseObject() {
        do {
            let hookClosure = {} as @convention(block) () -> Void as AnyObject
            XCTAssertNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
            
            try autoreleasepool {
                let testObject = TestObject()
                XCTAssertFalse(try isDynamicClass(object: testObject))
                
                let context: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
                
                XCTAssertTrue(try isDynamicClass(object: testObject))
                XCTAssertNotNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
                XCTAssertTrue(debugGetDynamicClassContextAsAnyObject(object: testObject) === debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
                XCTAssertTrue(class_getSuperclass(context) == TestObject.self)
                XCTAssertEqual(NSStringFromClass(context), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
            }
            XCTAssertNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testReleaseAllClosure() {
        do {
            let testObject = TestObject()
            XCTAssertFalse(try isDynamicClass(object: testObject))
            
            try autoreleasepool {
                let hookClosure = {} as @convention(block) () -> Void as AnyObject
                XCTAssertNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
                
                let context: AnyClass = try wrapDynamicClass(object: testObject, hookClosure: hookClosure)
                
                XCTAssertTrue(try isDynamicClass(object: testObject))
                XCTAssertNotNil(debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
                XCTAssertTrue(debugGetDynamicClassContextAsAnyObject(object: testObject) === debugGetDynamicClassContextAsAnyObject(closure: hookClosure))
                XCTAssertTrue(class_getSuperclass(context) == TestObject.self)
                XCTAssertEqual(NSStringFromClass(context), "SwiftHook_\(TestObject.self)_\(Unmanaged.passUnretained(testObject).toOpaque())")
            }
            XCTAssertFalse(try isDynamicClass(object: testObject))
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
