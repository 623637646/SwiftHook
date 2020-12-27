//
//  SingleInstancesInsteadTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SingleInstancesInsteadTests: XCTestCase {
    
    func testCallOriginal() {
        do {
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, o, s, a, b in
                    let result = original(o, s, a, b)
                    XCTAssertEqual(result, a + b)
                    return result
                    } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int
                let token = try internalHook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testOverrideOriginal() {
        do {
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, o, s, a, b in
                    let result = original(o, s, a, b)
                    XCTAssertEqual(result, a + b)
                    return a * b
                    } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int
                let token = try internalHook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA * argumentB)
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testChangeArgs() {
        do {
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .instead
                let closure = { original, o, s, a, b in
                    let result = original(o, s, a * 2, b * 2)
                    XCTAssertEqual(result, a * 2 + b * 2)
                    return result
                    } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int
                let token = try internalHook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA * 2 + argumentB * 2)
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token)!)
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNonCallOriginal() {
        do {
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.execute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                let closure = { _, _, _, _ in
                    XCTAssertEqual(result, [])
                    result.append(1)
                    result.append(3)
                    } as @convention(block) ((AnyObject, Selector, ExecuteType) -> Void, AnyObject, Selector, ExecuteType) -> Void
                let token = try internalHook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTFail()
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 3])
                
                // cancel
                
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testCallOriginalForClosure() {
        do {
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let selector = #selector(TestObject.execute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                let closure = { original, o, s, arg in
                    XCTAssertEqual(result, [])
                    result.append(1)
                    original(o, s, arg)
                    result.append(3)
                    } as @convention(block) (@escaping (AnyObject, Selector, ExecuteType) -> Void, AnyObject, Selector, ExecuteType) -> Void
                let token = try internalHook(object: test, selector: selector, mode: mode, hookClosure: closure as AnyObject)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTAssertEqual(result, [1])
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 2, 3])
                
                // cancel
                
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookTwice() {
        do {
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                let selector = #selector(TestObject.execute(closure:))
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                
                // first hook
                let token1 = try internalHook(object: test, selector: selector, mode: mode, hookClosure: { original, o, s, arg in
                    result.append(1)
                    original(o, s, arg)
                    result.append(2)
                    } as @convention(block) (@escaping (AnyObject, Selector, ExecuteType) -> Void, AnyObject, Selector, ExecuteType) -> Void as AnyObject)
                
                // second hook
                let token2 = try internalHook(object: test, selector: selector, mode: mode, hookClosure: { original, o, s, arg in
                    result.append(3)
                    original(o, s, arg)
                    result.append(4)
                    } as @convention(block) (@escaping (AnyObject, Selector, ExecuteType) -> Void, AnyObject, Selector, ExecuteType) -> Void as AnyObject)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    result.append(5)
                }
                XCTAssertEqual(result, [3, 1, 5, 2, 4])
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertFalse(internalCancelHook(token: token1)!)
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token2)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookTwiceWithDifferentMethod() {
        do {
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                typealias ExecuteType = () -> Void
                let mode: HookMode = .instead
                
                // first hook
                let token1 = try internalHook(object: test, selector: #selector(TestObject.execute(closure:)), mode: mode, hookClosure: { original, o, s, arg in
                    result.append(1)
                    original(o, s, arg)
                    result.append(2)
                    } as @convention(block) (@escaping (AnyObject, Selector, ExecuteType) -> Void, AnyObject, Selector, ExecuteType) -> Void as AnyObject)
                
                // second hook
                let token2 = try internalHook(object: test, selector: #selector(TestObject.sumFunc(a:b:)), mode: mode, hookClosure: { original, o, s, a, b in
                    let result = original(o, s, a, b)
                    XCTAssertEqual(result, a + b)
                    return result
                    } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int as AnyObject)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    result.append(5)
                }
                XCTAssertEqual(result, [1, 5, 2])
                XCTAssertEqual(test.sumFunc(a: 55, b: 45), 55 + 45)
                XCTAssertEqual(result, [1, 5, 2])
                
                // cancel
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertFalse(internalCancelHook(token: token1)!)
                XCTAssertTrue(try testGetObjectType(object: test) == .dynamic)
                XCTAssertTrue(internalCancelHook(token: token2)!)
                result.removeAll()
            }
            
            // test cancel
            XCTAssertTrue(try testGetObjectType(object: test) == .normal)
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testChangeReturn() {
        do {
            let object = TestObject()
            let token = try hookInstead(object: object, selector: #selector(TestObject.generateNumber(number:)), closure: { original, o, s, number in
                XCTAssertEqual(number, 4)
                let number = original(o, s, 5)
                XCTAssertEqual(number.intValue, 5)
                let newNumber = NSNumber(6)
                return newNumber
                } as @convention(block) ((AnyObject, Selector, Int) -> NSNumber, AnyObject, Selector, Int) -> NSNumber)
            let number = object.generateNumber(number: 4)
            XCTAssertEqual(number.intValue, 6)
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertTrue(internalCancelHook(token: hookToken)!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
