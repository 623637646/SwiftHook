//
//  HookContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 21/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextTests: XCTestCase {
    
    let InternalErrorNoMethod = 197
    
    func testNoMethod() {
        do {
            _ = try HookContext.init(targetClass: TestObject.self, selector: #selector(SuperObject.superFuncNoArgs), isSpecifiedInstance: false)
            XCTFail()
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("HookContext.swift"))
            XCTAssertEqual(line, InternalErrorNoMethod)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHook() {
        do {
            var result = [Int]()
            let context = try HookContext.init(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)), isSpecifiedInstance: false)
            XCTAssertTrue(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: {
                result.append(-1)
                } as @convention(block) () -> Void as AnyObject, mode: .before)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: {
                result.append(-2)
                } as @convention(block) () -> Void as AnyObject, mode: .before)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: { original, o, s, execute in
                result.append(-3)
                original(o, s, execute)
                result.append(3)
                } as @convention(block) (@escaping (AnyObject, Selector, () -> Void) -> Void, AnyObject, Selector, () -> Void) -> Void as AnyObject, mode: .instead)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: { original, o, s, execute in
                result.append(-4)
                original(o, s, execute)
                result.append(4)
                } as @convention(block) (@escaping (AnyObject, Selector, () -> Void) -> Void, AnyObject, Selector, () -> Void) -> Void as AnyObject, mode: .instead)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: {
                result.append(1)
                } as @convention(block) () -> Void as AnyObject, mode: .after)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: {
                result.append(2)
                } as @convention(block) () -> Void as AnyObject, mode: .after)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            let object = TestObject()
            XCTAssertEqual(result, [])
            object.execute {
                result.append(0)
            }
            XCTAssertEqual(result, [-4, -3, -2, -1, 0, 2, 1, 3, 4])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAppend() {
        do {
            let context = try HookContext.init(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)), isSpecifiedInstance: false)
            XCTAssertTrue(context.isHoolClosurePoolEmpty())
            
            let closure = {
                } as @convention(block) () -> Void as AnyObject
            
            let mode = randomMode()
            
            try context.append(hookClosure: closure, mode: mode)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            do {
                try context.append(hookClosure: closure, mode: mode)
                XCTFail()
            } catch SwiftHookError.duplicateHookClosure {
            } catch {
                XCTAssertNil(error)
            }
            
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testRemove() {
        do {
            let context = try HookContext.init(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)), isSpecifiedInstance: false)
            XCTAssertTrue(context.isHoolClosurePoolEmpty())
            
            let closure = {
                } as @convention(block) () -> Void as AnyObject
            
            let mode = randomMode()
            
            try context.append(hookClosure: closure, mode: mode)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.remove(hookClosure: closure, mode: mode)
            XCTAssertTrue(context.isHoolClosurePoolEmpty())
            
            do {
                try context.remove(hookClosure: closure, mode: mode)
                XCTFail()
            } catch SwiftHookError.internalError(file: let file, line: _) {
                XCTAssertTrue(file.hasSuffix("HookContext.swift"))
            } catch {
                XCTAssertNil(error)
            }
            
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_remove_hookContext_after_hook_cancellation_for_all_instances() throws {
        class MyObject {
            @objc dynamic func myMethod() {
            }
        }
        
        // before
        let countBefore = debug_getNormalClassHookContextsCount()
        
        // hook
        let token: HookToken! = try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.myMethod), closure: {
            
        }) as? HookToken
        
        // check
        XCTAssertNotNil(token)
        XCTAssertNotNil(token.hookContext)
        XCTAssertNotNil(token.hookClosure)
        XCTAssertNil(token.hookObject)
        XCTAssertEqual(token.mode, .after)
        XCTAssertEqual(debug_getNormalClassHookContextsCount(), countBefore + 1)
        
        // cancel
        XCTAssertEqual(try internalCancelHook(token: token), true)
        
        // check
        XCTAssertEqual(debug_getNormalClassHookContextsCount(), countBefore)
    }
    
    func test_keep_hookContext_after_instance_deinit() throws {
        class MyObject {
            @objc dynamic func myMethod() {
            }
        }
        let countBefore = debug_getinstancewHookContextsCount()
        var token1: HookToken!
        try autoreleasepool {
            let object = MyObject.init()
            token1 = try hookAfter(object: object, selector: #selector(MyObject.myMethod), closure: {
            }) as? HookToken
            XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
        }
        XCTAssertNotNil(token1)
        XCTAssertNotNil(token1.hookContext)
        XCTAssertNil(token1.hookClosure)
        XCTAssertNil(token1.hookObject)
        XCTAssertEqual(token1.mode, .after)
        XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
        
        var token2: HookToken!
        try autoreleasepool {
            let object = MyObject.init()
            token2 = try hookAfter(object: object, selector: #selector(MyObject.myMethod), closure: {
            }) as? HookToken
            XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
        }
        XCTAssertNotNil(token2)
        XCTAssertNotNil(token2.hookContext)
        XCTAssertNil(token2.hookClosure)
        XCTAssertNil(token2.hookObject)
        XCTAssertEqual(token2.mode, .after)
        XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
    }
    
    func test_keep_hookContext_after_cancellation_for_specified_instance() throws {
        class MyObject {
            @objc dynamic func myMethod() {
            }
        }
        let countBefore = debug_getinstancewHookContextsCount()
        
        let object1 = MyObject.init()
        let token1: HookToken! = try hookAfter(object: object1, selector: #selector(MyObject.myMethod), closure: {
        }) as? HookToken
        
        // check
        XCTAssertNotNil(token1)
        XCTAssertNotNil(token1.hookContext)
        XCTAssertNotNil(token1.hookClosure)
        XCTAssertNotNil(token1.hookObject)
        XCTAssertEqual(token1.mode, .after)
        XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
        
        // cancel
        XCTAssertEqual(try internalCancelHook(token: token1), true)
        
        // check
        XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
        
        let object2 = MyObject.init()
        let token2: HookToken! = try hookAfter(object: object2, selector: #selector(MyObject.myMethod), closure: {
        }) as? HookToken
        
        // check
        XCTAssertNotNil(token2)
        XCTAssertNotNil(token2.hookContext)
        XCTAssertNotNil(token2.hookClosure)
        XCTAssertNotNil(token2.hookObject)
        XCTAssertEqual(token2.mode, .after)
        XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
        
        // cancel
        XCTAssertEqual(try internalCancelHook(token: token2), true)
        
        // check
        XCTAssertEqual(debug_getinstancewHookContextsCount(), countBefore + 1)
    }
    
}
