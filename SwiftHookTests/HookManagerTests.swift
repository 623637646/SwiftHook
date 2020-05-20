//
//  HookManagerTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookManagerTests: XCTestCase {
    
    override class func setUp() {
        HookManager.shared.cleanUpHookContextPool()
        cleanUpDynamicClassContextPool()
    }

    func testClassReuseHookContext() {
        let targetClass = TestObject.self
        let selector = #selector(SuperObject.superFunc(arg:))
        let count = HookManager.shared.debugGetNormalClassHookContextsCount()
        do {
            let token1 = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 1)
            
            let token2 = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 1)
            
            let token3 = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 1)
            
            let token4 = try HookManager.shared.hook(targetClass: SuperObject.self, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 2)
            
            let token5 = try HookManager.shared.hook(targetClass: targetClass, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 3)
            
            XCTAssertFalse(HookManager.shared.cancelHook(token: token1)!)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 3)
            
            XCTAssertFalse(HookManager.shared.cancelHook(token: token2)!)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 3)
            
            XCTAssertTrue(HookManager.shared.cancelHook(token: token3)!)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 2)
            
            XCTAssertTrue(HookManager.shared.cancelHook(token: token4)!)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count + 1)
            
            XCTAssertTrue(HookManager.shared.cancelHook(token: token5)!)
            XCTAssertEqual(HookManager.shared.debugGetNormalClassHookContextsCount(), count)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testObjectReuseHookContext() {
        let object = TestObject()
        let superObject = SuperObject()
        let selector = #selector(SuperObject.superFunc(arg:))
        let count = HookManager.shared.debugGetDynamicClassHookContextsCount()
        do {
            let token1 = try HookManager.shared.hook(object: object, selector: selector, mode: .before, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 2)
            
            let token2 = try HookManager.shared.hook(object: object, selector: selector, mode: .after, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 2)
            
            let token3 = try HookManager.shared.hook(object: object, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 2)
            
            let token4 = try HookManager.shared.hook(object: superObject, selector: selector, mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 4)
            
            let token5 = try HookManager.shared.hook(object: object, selector: #selector(TestObject.noDynamicMethod), mode: .instead, hookClosure: {
            } as @convention(block) () -> Void as AnyObject)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertFalse(HookManager.shared.cancelHook(token: token1)!)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertFalse(HookManager.shared.cancelHook(token: token2)!)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertFalse(HookManager.shared.cancelHook(token: token3)!)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertTrue(HookManager.shared.cancelHook(token: token4)!)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 5)
            
            XCTAssertTrue(HookManager.shared.cancelHook(token: token5)!)
            XCTAssertEqual(HookManager.shared.debugGetDynamicClassHookContextsCount(), count + 5)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
