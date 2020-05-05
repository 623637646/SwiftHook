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
    
    func testPureSwift() {
        let contextCount = OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count
        do {
            try OverrideMethodContext.overrideSuperMethod(targetClass: PureSwift.self, selector: #selector(TestObject.noArgsNoReturnFunc))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, 64)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, contextCount)
    }
    
    func testOverrideSelfMethod() {
        let contextCount = OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count
        do {
            try OverrideMethodContext.overrideSuperMethod(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, 58)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, contextCount)
    }

    func testOverrideNonSuperMethod() {
        let contextCount = OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count
        do {
            try OverrideMethodContext.overrideSuperMethod(targetClass: TestObject.self, selector: #selector(getter: UIView.alpha))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, 64)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, contextCount)
    }
    
    func testOverrideSuperMethod() {
        let targetClass = TestObject.self
        let selector = #selector(TestObject.superFunc(arg:))
        
        // beginning
        let contextCount = OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count
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
        XCTAssertEqual(OverrideMethodContext.debugToolsGetAllOverrideMethodContext().count, contextCount + 1)
        
        guard let methodChildAfter = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertNotEqual(methodChildAfter, methodSuper)
        
        let resultAfter = object.superFunc(arg: [])
        XCTAssertEqual(resultAfter.count, 1)
        XCTAssertTrue(resultAfter.first! == SuperObject.self)
    }
    
}
