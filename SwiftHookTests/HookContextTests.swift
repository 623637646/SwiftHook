//
//  HookContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 6/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextTests: XCTestCase {
    
    let InternalErrorLineSignature = 69
    let InternalErrorLineMethod = 62
    
    // MARK: invalid closure
    
    func testInvalidClosureWithSwiftClosure() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = {} as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSignature)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInvalidClosureWithSwiftObject() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = PureSwift()
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSignature)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInvalidClosureWithObjectiveCObject() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = NSObject()
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSignature)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: invalid class & selector
    
    func testPureSwift() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = PureSwift.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }

    func testHookNoRespondSelector() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: No method from self.
    
    func testNoMethodFromSelf() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.superFunc(arg:))
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: All instances & before
    
    // TODO: 
    func testAllInstancesBefore() {
//        do {
//            // hook
//            let contextCount = HookContext.debugToolsGetAllHookContext().count
//            let targetClass = TestObject.self
//            let selector = #selector(TestObject.execute(closure:))
//            let mode: HookMode = .before
//            var result = [Int]()
//            let closure = {
//                result.append(1)
//                } as @convention(block) () -> Void as AnyObject
//            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
//            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
//            
//            // test hook
//            let test = TestObject()
//            XCTAssertEqual(result, [])
//            test.execute {
//                XCTAssertEqual(result, [1])
//                result.append(2)
//            }
//            XCTAssertEqual(result, [1, 2])
//            
//            // cancel
//            hookContext.cancelHook()
//            result.removeAll()
//            
//            // test cancel
//            test.execute {
//                XCTAssertEqual(result, [])
//                result.append(2)
//            }
//            XCTAssertEqual(result, [2])
//            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
//            
//        } catch {
//            XCTAssertNil(error)
//        }
    }
    
}
