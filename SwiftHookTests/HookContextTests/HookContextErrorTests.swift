//
//  HookContextErrorTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextErrorTests: XCTestCase {

    let InternalErrorLineSignature = 112
    let InternalErrorLineMethod = 104
    
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
        } catch SwiftHookError.missingSignature {
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
        } catch SwiftHookError.missingSignature {
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
        } catch SwiftHookError.missingSignature {
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
    
    // MARK: closure signature doesn't match method
    
    func testBeforeNoVoidReturn() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.sumFunc(a:b:))
        let mode: HookMode = .before
        let closure = ({ _, _ in  return 1} as @convention(block) (Int, Int) -> Int) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testBeforeNoMatchArguments() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.sumFunc(a:b:))
        let mode: HookMode = .before
        let closure = ({ _, _ in return 1 } as @convention(block) (Int, Double) -> Int) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testAfterNoMatchArguments() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.testStructSignature(point:rect:))
        let mode: HookMode = .after
        let closure = ({_, _ in } as @convention(block) (CGPoint, Double) -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInsteadNoMatchArguments() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.testStructSignature(point:rect:))
        let mode: HookMode = .instead
        let closure = ({_, _ in } as @convention(block) (CGPoint, CGRect) -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
}
