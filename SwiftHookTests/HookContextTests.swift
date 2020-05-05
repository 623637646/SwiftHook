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
    
    func testInvalidBlock() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let block: AnyObject = {} as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookBlock: block)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, 73)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testPureSwift() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = PureSwift.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let block: AnyObject = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookBlock: block)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, 73)
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
        let block: AnyObject = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookBlock: block)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, 73)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
}
