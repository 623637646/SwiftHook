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
    
    override class func setUp() {
        cleanUpHookContextPool()
        cleanUpDynamicClassContextPool()
    }

    func testClassReuseHookContext() {
        let targetClass = TestObject.self
        let selector = #selector(SuperObject.superFunc(arg:))
        let count = debugGetNormalClassHookContextsCount()
        do {
            let token1 = try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 1)
            
            let token2 = try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 1)
            
            let token3 = try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 1)
            
            let token4 = try internalHook(targetClass: SuperObject.self, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 2)
            
            let token5 = try internalHook(targetClass: targetClass, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 3)
            
            XCTAssertFalse(internalCancelHook(token: token1)!)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 3)
            
            XCTAssertFalse(internalCancelHook(token: token2)!)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 3)
            
            XCTAssertTrue(internalCancelHook(token: token3)!)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 2)
            
            XCTAssertTrue(internalCancelHook(token: token4)!)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count + 1)
            
            XCTAssertTrue(internalCancelHook(token: token5)!)
            XCTAssertEqual(debugGetNormalClassHookContextsCount(), count)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testObjectReuseHookContext() {
        let object = TestObject()
        let superObject = SuperObject()
        let selector = #selector(SuperObject.superFunc(arg:))
        let count = debugGetDynamicClassHookContextsCount()
        do {
            let token1 = try internalHook(object: object, selector: selector, mode: .before, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 2)
            
            let token2 = try internalHook(object: object, selector: selector, mode: .after, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 2)
            
            let token3 = try internalHook(object: object, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 2)
            
            let token4 = try internalHook(object: superObject, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 4)
            
            let token5 = try internalHook(object: object, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertFalse(internalCancelHook(token: token1)!)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertFalse(internalCancelHook(token: token2)!)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertFalse(internalCancelHook(token: token3)!)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertTrue(internalCancelHook(token: token4)!)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertTrue(internalCancelHook(token: token5)!)
            XCTAssertEqual(debugGetDynamicClassHookContextsCount(), count + 5)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
