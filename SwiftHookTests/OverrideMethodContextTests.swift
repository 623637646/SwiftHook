//
//  OverrideMethodContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 5/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class TestsPureSwift {
    
}

class TestsSuperObject: NSObject {
    @objc dynamic func superFunc(arg: [AnyClass]) -> [AnyClass] {
        var arg = arg
        arg.append(TestsSuperObject.self)
        return arg
    }
}

class TestsTestObject: TestsSuperObject {
    
    @objc dynamic func selfFunc() {
        
    }
}

class OverrideMethodContextTests: XCTestCase {
    
    let InternalErrorLineMethod = 52
    let InternalErrorLineSuperMethod = 57
    
    func testPureSwift() {
        let contextCount = HookManager.shared.debugToolsGetAllOverrideMethodContext().count
        do {
            try HookManager.shared.overrideSuperMethod(targetClass: TestsPureSwift.self, selector: #selector(TestsTestObject.selfFunc))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSuperMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllOverrideMethodContext().count, contextCount)
    }
    
    func testOverrideSelfMethod() {
        let contextCount = HookManager.shared.debugToolsGetAllOverrideMethodContext().count
        do {
            try HookManager.shared.overrideSuperMethod(targetClass: TestsTestObject.self, selector: #selector(TestsTestObject.selfFunc))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllOverrideMethodContext().count, contextCount)
    }

    func testOverrideNonSuperMethod() {
        let contextCount = HookManager.shared.debugToolsGetAllOverrideMethodContext().count
        do {
            try HookManager.shared.overrideSuperMethod(targetClass: TestsTestObject.self, selector: #selector(getter: UIView.alpha))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(OverrideMethodContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSuperMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllOverrideMethodContext().count, contextCount)
    }
    
    func testOverrideSuperMethod() {
        let targetClass = TestsTestObject.self
        let selector = #selector(TestsTestObject.superFunc(arg:))
        
        // beginning
        let contextCount = HookManager.shared.debugToolsGetAllOverrideMethodContext().count
        guard let methodChild = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSuper = class_getInstanceMethod(TestsSuperObject.self, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(methodChild, methodSuper)
        
        let object = TestsTestObject()
        let result = object.superFunc(arg: [])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.first! == TestsSuperObject.self)
        
        // added method
        do {
            try HookManager.shared.overrideSuperMethod(targetClass: TestsTestObject.self, selector: selector)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookManager.shared.debugToolsGetAllOverrideMethodContext().count, contextCount + 1)
        
        guard let methodChildAfter = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertNotEqual(methodChildAfter, methodSuper)
        
        let resultAfter = object.superFunc(arg: [])
        XCTAssertEqual(resultAfter.count, 1)
        XCTAssertTrue(resultAfter.first! == TestsSuperObject.self)
    }
    
}
