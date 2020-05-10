//
//  HookContextAllInstancesAfterTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextAllInstancesAfterTests: XCTestCase {

    // MARK: All instances & after
    
    func testAllInstancesAfter() {
        do {
            let contextCount = HookContext.debugToolsGetAllHookContext().count
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let targetClass = TestObject.self
                let selector = #selector(TestObject.execute(closure:))
                let mode: HookMode = .after
                let closure = {
                    XCTAssertEqual(result, [2])
                    result.append(1)
                    } as @convention(block) () -> Void as AnyObject
                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTAssertEqual(result, [])
                    result.append(2)
                }
                XCTAssertEqual(result, [2, 1])
                
                // cancel
                
                XCTAssertTrue(hookContext.cancelHook())
                result.removeAll()
            }
            
            // test cancel
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAllInstancesAfterCheckArguments() {
        do {
            let contextCount = HookContext.debugToolsGetAllHookContext().count
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let targetClass = TestObject.self
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .after
                let closure = { a, b in
                    XCTAssertEqual(argumentA, a)
                    XCTAssertEqual(argumentB, b)
                    } as @convention(block) (Int, Int) -> Void as AnyObject
                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                
                // cancel
                XCTAssertTrue(hookContext.cancelHook())
            }
            
            // test cancel
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }

}
