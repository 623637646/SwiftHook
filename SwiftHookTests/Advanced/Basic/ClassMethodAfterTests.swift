//
//  ClassMethodAfterTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class ClassMethodAfterTests: XCTestCase {

    func testNormal() {
        do {
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodExecute(closure:))
                let mode: HookMode = .after
                let closure = {
                    XCTAssertEqual(result, [2])
                    result.append(1)
                    } as @convention(block) () -> Void
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(HookContext.classHookContextsCount(), 1)
                
                // test hook
                XCTAssertEqual(result, [])
                TestObject.classMethodExecute {
                    XCTAssertEqual(result, [])
                    result.append(2)
                }
                XCTAssertEqual(result, [2, 1])
                
                // cancel
                
                XCTAssertTrue(try internalCancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            TestObject.classMethodExecute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(HookContext.classHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCheckArguments() {
        do {
            let argumentA = 77
            let argumentB = 88
            var executed = false
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodSumFunc(a:b:))
                let mode: HookMode = .after
                let closure = {_, _, a, b in
                    XCTAssertEqual(argumentA, a)
                    XCTAssertEqual(argumentB, b)
                    executed = true
                    } as @convention(block) (AnyObject, Selector, Int, Int) -> Void
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(HookContext.classHookContextsCount(), 1)
                
                // test hook
                let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                XCTAssertTrue(executed)
                
                // cancel
                XCTAssertTrue(try internalCancelHook(token: token)!)
            }
            
            // test cancel
            executed = false
            let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertFalse(executed)
            XCTAssertEqual(HookContext.classHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }

}
