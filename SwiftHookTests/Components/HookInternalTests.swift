//
//  HookInternalTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookInternalTests: XCTestCase {
    
    func testHookClass() {
        let targetClass = TestObject.self
        let selector = #selector(SuperObject.superFunc(arg:))
        do {
            let count = debug_getNormalClassHookContextsCount()
            let token1 = try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 1)
            
            let token2 = try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 1)
            
            let token3 = try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 1)
            
            let token4 = try internalHook(targetClass: SuperObject.self, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 2)
            
            let token5 = try internalHook(targetClass: targetClass, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 3)
            
            XCTAssertFalse(try internalCancelHook(token: token1)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 3)
            
            XCTAssertFalse(try internalCancelHook(token: token2)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 3)
            
            XCTAssertTrue(try internalCancelHook(token: token3)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 2)
            
            XCTAssertTrue(try internalCancelHook(token: token4)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count + 1)
            
            XCTAssertTrue(try internalCancelHook(token: token5)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), count)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookObject() {
        let object = TestObject()
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        let superObject = SuperObject()
        XCTAssertTrue(try testGetObjectType(object: superObject) == .normal)
        let selector = #selector(SuperObject.superFunc(arg:))
        do {
            let token1 = try internalHook(object: object, selector: selector, mode: .before, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 1)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            let token2 = try internalHook(object: object, selector: selector, mode: .after, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 2)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            let token3 = try internalHook(object: object, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 3)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            let token4 = try internalHook(object: superObject, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: superObject), 1)
            XCTAssertTrue(try testGetObjectType(object: superObject) == .dynamic)
            
            let token5 = try internalHook(object: object, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 4)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            XCTAssertFalse(try internalCancelHook(token: token1)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 3)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            XCTAssertFalse(try internalCancelHook(token: token2)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 2)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            XCTAssertFalse(try internalCancelHook(token: token3)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 1)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            
            XCTAssertTrue(try internalCancelHook(token: token4)!)
            XCTAssertEqual(debug_hookClosureCount(object: superObject), 0)
            XCTAssertTrue(try testGetObjectType(object: superObject) == .normal)
            
            XCTAssertTrue(try internalCancelHook(token: token5)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 0)
            XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testDuplicateCancellation() {
        do {
            let token1 = try internalHook(targetClass: TestObject.self, selector: #selector(SuperObject.superFunc(arg:)), mode: .before, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertTrue(try internalCancelHook(token: token1)!)
            XCTAssertNil(try internalCancelHook(token: token1))
            XCTAssertNil(try internalCancelHook(token: token1))
            
            let object = TestObject()
            let token2 = try internalHook(object: object, selector: #selector(SuperObject.superFunc(arg:)), mode: .after, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertTrue(try internalCancelHook(token: token2)!)
            XCTAssertNil(try internalCancelHook(token: token2))
            XCTAssertNil(try internalCancelHook(token: token2))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testDuplicateHookClosure() {
        do {
            let closure: @convention(block) () -> Void = {
            }
            let token = try internalHook(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            defer {
                XCTAssertTrue(try internalCancelHook(token: token)!)
            }
            _ = try internalHook(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            XCTFail()
        } catch SwiftHookError.duplicateHookClosure {
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            let closure: @convention(block) () -> Void = {
            }
            let token1 = try internalHook(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            let token2 = try internalHook(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .after, hookClosure: closure as AnyObject)
            XCTAssertFalse(try internalCancelHook(token: token1)!)
            XCTAssertTrue(try internalCancelHook(token: token2)!)
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            let object = TestObject()
            let closure: @convention(block) () -> Void = {
            }
            let token = try internalHook(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            defer {
                XCTAssertTrue(try internalCancelHook(token: token)!)
            }
            _ = try internalHook(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            XCTFail()
        } catch SwiftHookError.duplicateHookClosure {
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            let object = TestObject()
            let closure: @convention(block) () -> Void = {
            }
            let token1 = try internalHook(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            let token2 = try internalHook(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .after, hookClosure: closure as AnyObject)
            XCTAssertFalse(try internalCancelHook(token: token1)!)
            XCTAssertTrue(try internalCancelHook(token: token2)!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
