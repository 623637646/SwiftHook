//
//  SingleInstancesAfterTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SingleInstancesAfterTests: XCTestCase {

    func testNormal() {
        do {
            let hookedTestObject = TestObject()
            let nonHookTestObject = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.execute(closure:))
                let mode: HookMode = .after
                let closure = {
                    XCTAssertEqual(result, [2])
                    result.append(1)
                    } as @convention(block) () -> Void
                let token = try internalHook(object: hookedTestObject, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                XCTAssertEqual(result, [])
                hookedTestObject.execute {
                    XCTAssertEqual(result, [])
                    result.append(2)
                }
                XCTAssertEqual(result, [2, 1])
                
                nonHookTestObject.execute {
                    XCTAssertEqual(result, [2, 1])
                    result.append(3)
                    XCTAssertEqual(result, [2, 1, 3])
                }
                XCTAssertEqual(result, [2, 1, 3])
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: hookedTestObject) == .dynamic)
                XCTAssertTrue(try internalCancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: hookedTestObject) == .normal)
            hookedTestObject.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCheckArguments() {
        do {
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            var executed = false
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .after
                let closure = {_, _, a, b in
                    XCTAssertEqual(argumentA, a)
                    XCTAssertEqual(argumentB, b)
                    executed = true
                    } as @convention(block) (AnyObject, Selector, Int, Int) -> Void
                let token = try internalHook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                XCTAssertTrue(executed)
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(try internalCancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            executed = false
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertFalse(executed)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
