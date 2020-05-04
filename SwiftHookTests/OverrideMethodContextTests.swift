//
//  OverrideMethodContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 5/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class OverrideMethodContextTests: XCTestCase {
    
    func testOverrideSelfMethod() {
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, 0)
        do {
            try OverrideMethodContext.overrideSuperMethod(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("OverrideMethodContext.swift"))
            XCTAssertEqual(line, 58)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, 0)
    }

    func testOverrideNonSuperMethod() {
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, 0)
        do {
            try OverrideMethodContext.overrideSuperMethod(targetClass: TestObject.self, selector: #selector(getter: UIView.alpha))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("OverrideMethodContext.swift"))
            XCTAssertEqual(line, 64)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, 0)
    }
    
    func testOverrideSuperMethod() {
        let targetClass = TestObject.self
        let selector = #selector(TestObject.superFunc(arg:))
        
        // beginning
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, 0)
        guard let methodChild = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSuper = class_getInstanceMethod(SuperObject.self, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(methodChild, methodSuper)
        
        let object = TestObject()
        let result = object.superFunc(arg: [])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.first! == SuperObject.self)
        
        // added method
        do {
            try OverrideMethodContext.overrideSuperMethod(targetClass: TestObject.self, selector: selector)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, 1)
        
        guard let methodChildAfter = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertNotEqual(methodChildAfter, methodSuper)
        
        let resultAfter = object.superFunc(arg: [])
        XCTAssertEqual(resultAfter.count, 1)
        XCTAssertTrue(resultAfter.first! == SuperObject.self)
    }
    
    // TODO: HookContext Tests.

}
