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
        DispatchQueue.concurrentPerform(iterations: 1000) { index in
            do {
                let targetClass: AnyClass = objc_allocateClassPair(TestObject.self, "ThreadSafetyTests_\(index)", 0)!
                objc_registerClassPair(targetClass)
                try hookAfter(targetClass: targetClass, selector: #selector(TestObject.noArgsNoReturnFunc)) {}
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
                    try hookInstead(object: TestObject(), selector: #selector(TestObject.noArgsNoReturnFunc), closure: { _ in
                        } as @convention(block) (() -> Void) -> Void)
                }
            } catch {
                XCTAssertNil(error)
            }
        }
    }
    
    func testCancelHook() {
        do {
            var tokens = [HookToken]()
            for _ in 0 ... 1000 {
                tokens.append(try HookManager.shared.hook(object: TestObject(), selector: #selector(TestObject.noArgsNoReturnFunc), mode: .instead, hookClosure: { _ in
                    } as @convention(block) (() -> Void) -> Void as AnyObject))
            }
            DispatchQueue.concurrentPerform(iterations: 1000) { index in
                tokens[index].cancelHook()
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
