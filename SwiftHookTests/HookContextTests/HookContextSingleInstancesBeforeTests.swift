//
//  HookContextSingleInstancesBeforeTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextSingleInstancesBeforeTests: XCTestCase {

    func testNormal() {
        do {
            let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
            let hookedTestObject = TestObject()
            let nonHookTestObject = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.execute(closure:))
                let mode: HookMode = .before
                let closure = {
                    XCTAssertEqual(result, [])
                    result.append(1)
                    } as @convention(block) () -> Void
                let hookContext = try HookManager.shared.hook(object: hookedTestObject, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount + 2)
                
                // test hook
                XCTAssertEqual(result, [])
                hookedTestObject.execute {
                    XCTAssertEqual(result, [1])
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 2])
                
                nonHookTestObject.execute {
                    XCTAssertEqual(result, [1, 2])
                    result.append(3)
                    XCTAssertEqual(result, [1, 2, 3])
                }
                XCTAssertEqual(result, [1, 2, 3])
                
                // cancel
                XCTAssertTrue(isDynamicClass(object: hookedTestObject))
                XCTAssertTrue(hookContext.cancelHook())
                result.removeAll()
            }
            
            // test cancel
            XCTAssertTrue(isNotDynamicClass(object: hookedTestObject))
            hookedTestObject.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCheckArguments() {
        do {
            let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            var executed = false
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .before
                let closure = { a, b in
                    XCTAssertEqual(argumentA, a)
                    XCTAssertEqual(argumentB, b)
                    executed = true
                    } as @convention(block) (Int, Int) -> Void
                let hookContext = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount + 2)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                XCTAssertTrue(executed)
                
                // cancel
                XCTAssertTrue(isDynamicClass(object: test))
                XCTAssertTrue(hookContext.cancelHook())
            }
            
            // test cancel
            XCTAssertTrue(isNotDynamicClass(object: test))
            executed = false
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertFalse(executed)
            XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
