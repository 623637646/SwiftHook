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
                XCTAssertTrue(internalCancelHook(token: hookToken)!)
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
    
    func testCancelHookForClass() {
        do {
            var tokens = [HookToken]()
            for _ in 0 ... 1000 {
                tokens.append(try internalHook(targetClass: randomTestClass(), selector: #selector(TestObject.noArgsNoReturnFunc), mode: randomMode(), hookClosure: { _, _, _ in
                    } as @convention(block) (AnyObject, Selector, () -> Void) -> Void as AnyObject))
            }
            DispatchQueue.concurrentPerform(iterations: 1000) { index in
                tokens[index].cancelHook()
//                _ = internalCancelHook(token: tokens[index]) // This will crash because of non-thread-safe
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCancelHookForObject() {
        do {
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
//                _ = internalCancelHook(token: tokens[index]) // This will not crash because of non-thread-safe
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCancelHookForHookDeallocAfterToken() {
        do {
            var tokens = [Token]()
            var objects = [AnyObject]()
            for _ in 0 ... 1000 {
                let object = randomTestObject()
                objects.append(object)
                tokens.append(try hookDeallocAfterByTail(object: object, closure: {
                }))
            }
            DispatchQueue.concurrentPerform(iterations: 1000) { index in
                tokens[index].cancelHook()
            }
        } catch {
            XCTAssertNil(error)
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
    
}
