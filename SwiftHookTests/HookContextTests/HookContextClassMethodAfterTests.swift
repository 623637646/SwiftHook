//
//  HookContextClassMethodAfterTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextClassMethodAfterTests: XCTestCase {

    func testAfter() {
        do {
            let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTAssertTrue(false)
                    return
                }
                let selector = #selector(TestObject.classMethodExecute(closure:))
                let mode: HookMode = .after
                let closure = {
                    XCTAssertEqual(result, [2])
                    result.append(1)
                    } as @convention(block) () -> Void
                let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                XCTAssertEqual(result, [])
                TestObject.classMethodExecute {
                    XCTAssertEqual(result, [])
                    result.append(2)
                }
                XCTAssertEqual(result, [2, 1])
                
                // cancel
                
                XCTAssertTrue(hookContext.cancelHook())
                result.removeAll()
            }
            
            // test cancel
            TestObject.classMethodExecute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAfterCheckArguments() {
        do {
            let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
            let argumentA = 77
            let argumentB = 88
            var executed = false
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTAssertTrue(false)
                    return
                }
                let selector = #selector(TestObject.classMethodSumFunc(a:b:))
                let mode: HookMode = .after
                let closure = { a, b in
                    XCTAssertEqual(argumentA, a)
                    XCTAssertEqual(argumentB, b)
                    executed = true
                    } as @convention(block) (Int, Int) -> Void
                let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                XCTAssertTrue(executed)
                
                // cancel
                XCTAssertTrue(hookContext.cancelHook())
            }
            
            // test cancel
            let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }

}
