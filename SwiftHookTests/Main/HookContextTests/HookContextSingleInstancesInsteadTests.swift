//
//  HookContextSingleInstancesInsteadTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextSingleInstancesInsteadTests: XCTestCase {

    func testCallOriginal() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a, b)
                    XCTAssertEqual(result, a + b)
                    return result
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int
                let token = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                
                // cancel
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testOverrideOriginal() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a, b)
                    XCTAssertEqual(result, a + b)
                    return a * b
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int
                let token = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA * argumentB)
                
                // cancel
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testChangeArgs() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a * 2, b * 2)
                    XCTAssertEqual(result, a * 2 + b * 2)
                    return result
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int
                let token = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA * 2 + argumentB * 2)
                
                // cancel
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNonCallOriginal() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.execute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                let closure = { original, arg in
                    XCTAssertEqual(result, [])
                    result.append(1)
                    result.append(3)
                    } as @convention(block) ((ExecuteType) -> Void, ExecuteType) -> Void
                let token = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTAssertTrue(false)
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 3])
                
                // cancel
                
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCallOriginalForClosure() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.execute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                let closure = { original, arg in
                    XCTAssertEqual(result, [])
                    result.append(1)
                    original(arg)
                    result.append(3)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void
                let token = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTAssertEqual(result, [1])
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 2, 3])
                
                // cancel
                
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookTwice() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                let selector = #selector(TestObject.execute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                
                // first hook
                let token1 = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: { original, arg in
                    result.append(1)
                    original(arg)
                    result.append(2)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // second hook
                let token2 = try HookManager.shared.hook(object: test, selector: selector, mode: mode, hookClosure: { original, arg in
                    result.append(3)
                    original(arg)
                    result.append(4)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    result.append(5)
                }
                XCTAssertEqual(result, [3, 1, 5, 2, 4])
                
                // cancel
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertFalse(HookManager.shared.cancelHook(token: token1)!)
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token2)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookTwiceWithDifferentMethod() {
        do {
//            let contextCount = HookManager.shared.debugGetNormalClassHookContextsCount()
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                
                // first hook
                let token1 = try HookManager.shared.hook(object: test, selector: #selector(TestObject.execute(closure:)), mode: mode, hookClosure: { original, arg in
                    result.append(1)
                    original(arg)
                    result.append(2)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 2)
                
                // second hook
                let token2 = try HookManager.shared.hook(object: test, selector: #selector(TestObject.sumFunc(a:b:)), mode: mode, hookClosure: { original, a, b in
                    let result = original(a, b)
                    XCTAssertEqual(result, a + b)
                    return result
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int as AnyObject)
//                XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount + 3)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    result.append(5)
                }
                XCTAssertEqual(result, [1, 5, 2])
                XCTAssertEqual(test.sumFunc(a: 55, b: 45), 55 + 45)
                XCTAssertEqual(result, [1, 5, 2])
                
                // cancel
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertFalse(HookManager.shared.cancelHook(token: token1)!)
                XCTAssertTrue(try testIsDynamicClass(object: test))
                XCTAssertTrue(HookManager.shared.cancelHook(token: token2)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertFalse(try testIsDynamicClass(object: test))
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
//            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
