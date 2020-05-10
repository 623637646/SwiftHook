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
    let InternalErrorLineMethod = 57
    
    // MARK: invalid closure
    
    func testInvalidClosureWithSwiftClosure() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = {}
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInvalidClosureWithSwiftObject() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = PureSwift()
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInvalidClosureWithObjectiveCObject() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = NSObject()
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: invalid class & selector
    
    func testPureSwift() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = PureSwift.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void)
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testHookNoRespondSelector() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void)
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: closure signature doesn't match method
    
    func testBeforeNoVoidReturn() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.sumFunc(a:b:))
        let mode: HookMode = .before
        let closure = ({ _, _ in  return 1} as @convention(block) (Int, Int) -> Int)
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testBeforeNoMatchArguments() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.sumFunc(a:b:))
        let mode: HookMode = .before
        let closure = ({ _, _ in return 1 } as @convention(block) (Int, Double) -> Int)
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testAfterNoMatchArguments() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.testStructSignature(point:rect:))
        let mode: HookMode = .after
        let closure = ({_, _ in } as @convention(block) (CGPoint, Double) -> Void)
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInsteadNoMatchArguments() {
        let contextCount = HookManager.shared.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.testStructSignature(point:rect:))
        let mode: HookMode = .instead
        let closure = ({_, _ in } as @convention(block) (CGPoint, CGRect) -> Void)
        do {
            let hookContext = try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllHookContext().count, contextCount)
    }
    
}
