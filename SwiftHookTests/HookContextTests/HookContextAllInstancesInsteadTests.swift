//
//  HookContextAllInstancesInsteadTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextAllInstancesInsteadTests: XCTestCase {
    
    // MARK: All instances & instead
    
    func testAllInstancesInstead() {
        do {
            let contextCount = HookContext.debugToolsGetAllHookContext().count
            let test = TestObject()
            
            try autoreleasepool {
                // hook
                let targetClass = TestObject.self
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a, b)
                    XCTAssertEqual(result, a + b)
                    return a * b
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int as AnyObject
                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                let result = test.sumFunc(a: 3, b: 4)
                XCTAssertEqual(result, 3 * 4)
                
                // cancel
                XCTAssertTrue(hookContext.cancelHook())
            }
            
            // test cancel
            let result = test.sumFunc(a: 6, b: 7)
            XCTAssertEqual(result, 6 + 7)
            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
        
        //        do {
        //            let contextCount = HookContext.debugToolsGetAllHookContext().count
        //            let test = TestObject()
        //            var result = [Int]()
        //
        //            try autoreleasepool {
        //                // hook
        //                let targetClass = TestObject.self
        //                let selector = #selector(TestObject.execute(closure:))
        //                typealias ExecuteType = () -> Void
        //                let mode: HookMode = .instead
        //                let closure = { original, arg in
        //                    XCTAssertEqual(result, [])
        //                    result.append(1)
        //                    original(arg)
        //                    result.append(3)
        //                    } as @convention(block) ((ExecuteType) -> Void, ExecuteType) -> Void as AnyObject
        //                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
        //                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
        //
        //                // test hook
        //                XCTAssertEqual(result, [])
        //                test.execute {
        //                    XCTAssertEqual(result, [])
        //                    result.append(2)
        //                }
        //                XCTAssertEqual(result, [1, 2, 3])
        //
        //                // cancel
        //
        //                XCTAssertTrue(hookContext.cancelHook())
        //                result.removeAll()
        //            }
        //
        //            // test cancel
        //            test.execute {
        //                XCTAssertEqual(result, [])
        //                result.append(2)
        //            }
        //            XCTAssertEqual(result, [2])
        //            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        //        } catch {
        //            XCTAssertNil(error)
        //        }
    }
    
}
