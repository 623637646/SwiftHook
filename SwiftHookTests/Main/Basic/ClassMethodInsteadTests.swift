//
//  ClassMethodInsteadTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class ClassMethodInsteadTests: XCTestCase {
    
    func testCallOriginal() {
        do {
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodSumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a, b)
                    XCTAssertEqual(result, a + b)
                    return result
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // test hook
                let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                
                // cancel
                XCTAssertTrue(internalCancelHook(token: token)!)
            }
            
            // test cancel
            let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testOverrideOriginal() {
        do {
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodSumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a, b)
                    XCTAssertEqual(result, a + b)
                    return a * b
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // test hook
                let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA * argumentB)
                
                // cancel
                XCTAssertTrue(internalCancelHook(token: token)!)
            }
            
            // test cancel
            let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testChangeArgs() {
        do {
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodSumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, a, b in
                    let result = original(a * 2, b * 2)
                    XCTAssertEqual(result, a * 2 + b * 2)
                    return result
                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // test hook
                let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA * 2 + argumentB * 2)
                
                // cancel
                XCTAssertTrue(internalCancelHook(token: token)!)
            }
            
            // test cancel
            let result = TestObject.classMethodSumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNonCallOriginal() {
        do {
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodExecute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                let closure = { original, arg in
                    XCTAssertEqual(result, [])
                    result.append(1)
                    result.append(3)
                    } as @convention(block) ((ExecuteType) -> Void, ExecuteType) -> Void
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // test hook
                XCTAssertEqual(result, [])
                TestObject.classMethodExecute {
                    XCTFail()
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 3])
                
                // cancel
                
                XCTAssertTrue(internalCancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            TestObject.classMethodExecute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCallOriginalForClosure() {
        do {
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodExecute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                let closure = { original, arg in
                    XCTAssertEqual(result, [])
                    result.append(1)
                    original(arg)
                    result.append(3)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void
                let token = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // test hook
                XCTAssertEqual(result, [])
                TestObject.classMethodExecute {
                    XCTAssertEqual(result, [1])
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 2, 3])
                
                // cancel
                
                XCTAssertTrue(internalCancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            TestObject.classMethodExecute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookTwice() {
        do {
            var result = [Int]()
            
            try autoreleasepool {
                guard let targetClass = object_getClass(TestObject.self) else {
                    XCTFail()
                    return
                }
                let selector = #selector(TestObject.classMethodExecute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                
                // first hook
                let token1 = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: { original, arg in
                    result.append(1)
                    original(arg)
                    result.append(2)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // second hook
                let token2 = try internalHook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: { original, arg in
                    result.append(3)
                    original(arg)
                    result.append(4)
                    } as @convention(block) (@escaping (ExecuteType) -> Void, ExecuteType) -> Void as AnyObject)
                XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
                
                // test hook
                XCTAssertEqual(result, [])
                TestObject.classMethodExecute {
                    result.append(5)
                }
                XCTAssertEqual(result, [3, 1, 5, 2, 4])
                
                // cancel
                XCTAssertFalse(internalCancelHook(token: token1)!)
                XCTAssertTrue(internalCancelHook(token: token2)!)
                result.removeAll()
            }
            
            // test cancel
            TestObject.classMethodExecute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testChangeReturn() {
        do {
            let token = try hookClassMethodInstead(targetClass: TestObject.self, selector: #selector(TestObject.classGenerateNumber(number:)), closure: { original, number in
                XCTAssertEqual(number, 4)
                let number = original(5)
                XCTAssertEqual(number.intValue, 5)
                let newNumber = NSNumber(6)
                return newNumber
            } as @convention(block) ((Int) -> NSNumber, Int) -> NSNumber)
            let number = TestObject.classGenerateNumber(number: 4)
            XCTAssertEqual(number.intValue, 6)
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
