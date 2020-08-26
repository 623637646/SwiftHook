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
            let token1 = try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
            
            let token2 = try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
            
            let token3 = try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
            
            let token4 = try internalHook(targetClass: SuperObject.self, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 2)
            
            let token5 = try internalHook(targetClass: targetClass, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 3)
            
            XCTAssertFalse(internalCancelHook(token: token1)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 3)
            
            XCTAssertFalse(internalCancelHook(token: token2)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 3)
            
            XCTAssertTrue(internalCancelHook(token: token3)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 2)
            
            XCTAssertTrue(internalCancelHook(token: token4)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 1)
            
            XCTAssertTrue(internalCancelHook(token: token5)!)
            XCTAssertEqual(debug_getNormalClassHookContextsCount(), 0)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookObject() {
        let object = TestObject()
        XCTAssertFalse(try testIsDynamicClass(object: object))
        let superObject = SuperObject()
        XCTAssertFalse(try testIsDynamicClass(object: superObject))
        let selector = #selector(SuperObject.superFunc(arg:))
        do {
            let token1 = try internalHook(object: object, selector: selector, mode: .before, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 1)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            let token2 = try internalHook(object: object, selector: selector, mode: .after, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 2)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            let token3 = try internalHook(object: object, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 3)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            let token4 = try internalHook(object: superObject, selector: selector, mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: superObject), 1)
            XCTAssertTrue(try testIsDynamicClass(object: superObject))
            
            let token5 = try internalHook(object: object, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {original, o, s, arg in
                return original(o, s, arg)
                } as @convention(block) ((AnyObject, Selector, [AnyClass]) -> [AnyClass], AnyObject, Selector, [AnyClass]) -> [AnyClass] as AnyObject)
            XCTAssertEqual(debug_hookClosureCount(object: object), 4)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            XCTAssertFalse(internalCancelHook(token: token1)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 3)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            XCTAssertFalse(internalCancelHook(token: token2)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 2)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            XCTAssertFalse(internalCancelHook(token: token3)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 1)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            
            XCTAssertTrue(internalCancelHook(token: token4)!)
            XCTAssertEqual(debug_hookClosureCount(object: superObject), 0)
            XCTAssertFalse(try testIsDynamicClass(object: superObject))
            
            XCTAssertTrue(internalCancelHook(token: token5)!)
            XCTAssertEqual(debug_hookClosureCount(object: object), 0)
            XCTAssertFalse(try testIsDynamicClass(object: object))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testDuplicateCancellation() {
        do {
            let token1 = try internalHook(targetClass: TestObject.self, selector: #selector(SuperObject.superFunc(arg:)), mode: .before, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertTrue(internalCancelHook(token: token1)!)
            XCTAssertNil(internalCancelHook(token: token1))
            XCTAssertNil(internalCancelHook(token: token1))
            
            let object = TestObject()
            let token2 = try internalHook(object: object, selector: #selector(SuperObject.superFunc(arg:)), mode: .after, hookClosure: {
                } as @convention(block) () -> Void as AnyObject)
            XCTAssertTrue(internalCancelHook(token: token2)!)
            XCTAssertNil(internalCancelHook(token: token2))
            XCTAssertNil(internalCancelHook(token: token2))
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
                XCTAssertTrue(internalCancelHook(token: token)!)
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
            XCTAssertFalse(internalCancelHook(token: token1)!)
            XCTAssertTrue(internalCancelHook(token: token2)!)
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            let object = TestObject()
            let closure: @convention(block) () -> Void = {
            }
            let token = try internalHook(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), mode: .before, hookClosure: closure as AnyObject)
            defer {
                XCTAssertTrue(internalCancelHook(token: token)!)
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
            XCTAssertFalse(internalCancelHook(token: token1)!)
            XCTAssertTrue(internalCancelHook(token: token2)!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
