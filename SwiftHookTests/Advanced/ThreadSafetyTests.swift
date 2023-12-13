//
//  ThreadSafetyTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class ThreadSafetyTests: XCTestCase {
    
    func testHookClassForSameClasses() {
        DispatchQueue.concurrentPerform(iterations: 1000) {_ in
            do {
                try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc)) {}
            } catch {
                XCTAssertNil(error)
            }
        }
    }
    
    func testHookClassForDifferentClasses() {
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            do {
                let targetClass: AnyClass = objc_allocateClassPair(TestObject.self, "ThreadSafetyTests_\(index)", 0)!
                objc_registerClassPair(targetClass)
                let token = try hookAfter(targetClass: targetClass, selector: #selector(TestObject.noArgsNoReturnFunc)) {}
                guard let hookToken = token as? HookToken else {
                    XCTFail()
                    return
                }
                XCTAssertTrue(try internalCancelHook(token: hookToken)!)
                objc_disposeClassPair(targetClass)
            } catch {
                XCTAssertNil(error)
            }
        }
    }
    
    func testHookObject() {
        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            do {
                _ = try autoreleasepool {
                    try hookInstead(object: TestObject(), selector: #selector(TestObject.noArgsNoReturnFunc), closure: { _, _, _ in
                    } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
                }
            } catch {
                XCTAssertNil(error)
            }
        }
    }
    
    func testCancelHookForClass() throws {
        var tokens = [HookToken]()
        for _ in 0 ... 1000 {
            tokens.append(try internalHook(targetClass: randomTestClass(), selector: #selector(TestObject.noArgsNoReturnFunc), mode: randomMode(), hookClosure: { _, _, _ in
            } as @convention(block) (AnyObject, Selector, () -> Void) -> Void as AnyObject))
        }
        DispatchQueue.concurrentPerform(iterations: 1000) { index in
            tokens[index].cancelHook()
            //                _ = try internalCancelHook(token: tokens[index]) // This will crash because of non-thread-safe
        }
    }
    
    func testCancelHookForObject() throws {
        var tokens = [HookToken]()
        var objects = [AnyObject]()
        for _ in 0 ... 1000 {
            let object = randomTestObject()
            objects.append(object)
            tokens.append(try internalHook(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), mode: randomMode(), hookClosure: {_, _, _ in
            } as @convention(block) (AnyObject, Selector, () -> Void) -> Void as AnyObject))
        }
        DispatchQueue.concurrentPerform(iterations: 1000) { index in
            tokens[index].cancelHook()
            //                _ = try internalCancelHook(token: tokens[index]) // This will not crash because of non-thread-safe
        }
    }
    
    func testCancelHookForHookDeallocAfterToken() throws {
        var tokens = [Token]()
        var objects = [AnyObject]()
        for _ in 0 ... 1000 {
            let object = randomTestObject()
            objects.append(object)
            tokens.append(hookDeallocAfterByTail(object: object, closure: {
            }))
        }
        DispatchQueue.concurrentPerform(iterations: 1000) { index in
            tokens[index].cancelHook()
        }
    }
    
    // This test case shows Swift is not thread safety.
    func testSwiftNotThreadSafety() {
        //        var object = TestObject()
        //        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
        //            object = TestObject()
        //        }
        //        _ = object
    }
    
    func test_instance_method_calling() throws {
        class MyObject {
            static var result = 0
            static let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
            @objc dynamic func plus1() {
                MyObject.serialQueue.async {
                    MyObject.result += 1
                }
            }
        }
        let object = MyObject.init()
        DispatchQueue.concurrentPerform(iterations: 1000) {_ in
            object.plus1()
        }
        var exp = expectation(description: "")
        MyObject.serialQueue.sync {
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertEqual(MyObject.result, 1000)
        }
        
        MyObject.result = 0
        try hookAfter(object: object, selector: #selector(MyObject.plus1), closure: { _, _ in
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
        } as @convention(block) (AnyObject, Selector) -> Void)
        try hookBefore(object: object, selector: #selector(MyObject.plus1), closure: { _, _ in
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
        } as @convention(block) (AnyObject, Selector) -> Void)
        try hookInstead(object: object, selector: #selector(MyObject.plus1), closure: { original, obj, selector in
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
            original(obj, selector)
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        
        DispatchQueue.concurrentPerform(iterations: 1000) {_ in
            object.plus1()
        }
        exp = expectation(description: "")
        MyObject.serialQueue.sync {
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertEqual(MyObject.result, 5000)
        }
    }

    func test_instance_method_calling_NSObject() throws {
        class MyObject: NSObject {
            static var result = 0
            static let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
            @objc dynamic func plus1() {
                MyObject.serialQueue.async {
                    MyObject.result += 1
                }
            }
        }
        let object = MyObject.init()
        DispatchQueue.concurrentPerform(iterations: 1000) {_ in
            object.plus1()
        }
        var exp = expectation(description: "")
        MyObject.serialQueue.sync {
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertEqual(MyObject.result, 1000)
        }
        
        MyObject.result = 0
        try hookAfter(object: object, selector: #selector(MyObject.plus1), closure: { _, _ in
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
        } as @convention(block) (AnyObject, Selector) -> Void)
        try hookBefore(object: object, selector: #selector(MyObject.plus1), closure: { _, _ in
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
        } as @convention(block) (AnyObject, Selector) -> Void)
        try hookInstead(object: object, selector: #selector(MyObject.plus1), closure: { original, obj, selector in
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
            original(obj, selector)
            MyObject.serialQueue.async {
                MyObject.result += 1
            }
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        
        DispatchQueue.concurrentPerform(iterations: 1000) {_ in
            object.plus1()
        }
        exp = expectation(description: "")
        MyObject.serialQueue.sync {
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertEqual(MyObject.result, 5000)
        }
    }
    
    func test_recursion() {
        class MyObject {
            @objc dynamic func myMethod(_ int: Int) -> Int {
                let int = int + 1
                guard int < 100 else {
                    return int
                }
                return self.myMethod(int)
            }
        }
        let object = MyObject.init()
        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            XCTAssertEqual(object.myMethod(0), 100)
        }
    }
    
    func test_recursion_NSObject() {
        class MyObject: NSObject {
            @objc dynamic func myMethod(_ int: Int) -> Int {
                let int = int + 1
                guard int < 100 else {
                    return int
                }
                return self.myMethod(int)
            }
        }
        let object = MyObject.init()
        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            XCTAssertEqual(object.myMethod(0), 100)
        }
    }
    
}
