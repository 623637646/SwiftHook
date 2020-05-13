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
//        do {
//            let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
//            let test = TestObject()
//            var result = [Int]()
//            
//            try autoreleasepool {
//                // hook
//                let selector = #selector(TestObject.execute(closure:))
//                let mode: HookMode = .before
//                let closure = {
//                    XCTAssertEqual(result, [])
//                    result.append(1)
//                    } as @convention(block) () -> Void
//                let hookContext = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount + 1)
//                
//                // test hook
//                XCTAssertEqual(result, [])
//                test.execute {
//                    XCTAssertEqual(result, [1])
//                    result.append(2)
//                }
//                XCTAssertEqual(result, [1, 2])
//                TestObject().execute {
//                    XCTAssertEqual(result, [1, 2])
//                    result.append(3)
//                    XCTAssertEqual(result, [1, 2, 3])
//                }
//                XCTAssertEqual(result, [1, 2, 3])
//                
//                // cancel
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
//            XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
//        } catch {
//            XCTAssertNil(error)
//        }
    }
    
    func testCheckArguments() {
        
    }
    
}
