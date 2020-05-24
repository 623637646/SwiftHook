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
    
    let InternalErrorNoMethod = 233
    
    func testNoMethod() {
        do {
            _ = try HookContext.init(targetClass: TestObject.self, selector: #selector(SuperObject.superFuncNoArgs))
            XCTAssertTrue(false)
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
            let context = try HookContext.init(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)))
            XCTAssertTrue(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: {
                result.append(-1)
                } as @convention(block) () -> Void as AnyObject, mode: .before)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: {
                result.append(-2)
                } as @convention(block) () -> Void as AnyObject, mode: .before)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: { original, execute in
                result.append(-3)
                original(execute)
                result.append(3)
                } as @convention(block) (@escaping (() -> Void) -> Void, () -> Void) -> Void as AnyObject, mode: .instead)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            try context.append(hookClosure: { original, execute in
                result.append(-4)
                original(execute)
                result.append(4)
                } as @convention(block) (@escaping (() -> Void) -> Void, () -> Void) -> Void as AnyObject, mode: .instead)
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
            XCTAssertEqual(result, [-2, -1, -4, -3, 0, 3, 4, 2, 1])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAppend() {
        do {
            let context = try HookContext.init(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)))
            XCTAssertTrue(context.isHoolClosurePoolEmpty())
            
            let closure = {
                } as @convention(block) () -> Void as AnyObject
            
            let mode = randomMode()
            
            try context.append(hookClosure: closure, mode: mode)
            XCTAssertFalse(context.isHoolClosurePoolEmpty())
            
            do {
                try context.append(hookClosure: closure, mode: mode)
                XCTAssertTrue(false)
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
            let context = try HookContext.init(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)))
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
                XCTAssertTrue(false)
            } catch SwiftHookError.internalError(file: let file, line: _) {
                XCTAssertTrue(file.hasSuffix("HookContext.swift"))
            } catch {
                XCTAssertNil(error)
            }
            
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
