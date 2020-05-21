//
//  OverrideSuperMethodTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 5/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class OverrideSuperOCObject: NSObject {
    @objc dynamic func superFunc(arg: [AnyClass]) -> [AnyClass] {
        var arg = arg
        arg.append(OverrideSuperOCObject.self)
        return arg
    }
    
    dynamic func superFuncWithoutObjc() {
        
    }
    
    @objc func superFuncWithoutDynamic() {
        
    }
}

class OverrideOCObject: OverrideSuperOCObject {
    
    @objc dynamic func selfFunc() {
        
    }
    
}

class OverrideSuperMethodTests: XCTestCase {
    
    let InternalExistingMethod = 55
    let InternalErrorCanNotGetMethod = 61
    
    // MARK: Wrong cases
    
    func testSelfExistingMethod() {
        let contextCount = debug_overrideMethodContextCount()
        do {
            try overrideSuperMethod(targetClass: OverrideOCObject.self, selector: #selector(OverrideOCObject.selfFunc))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("OverrideSuperMethod.swift"))
            XCTAssertEqual(line, InternalExistingMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(debug_overrideMethodContextCount(), contextCount)
    }
    
    func testCanNotGetMethod() {
        let contextCount = debug_overrideMethodContextCount()
        do {
            try overrideSuperMethod(targetClass: OverrideOCObject.self, selector: #selector(UIView.animate(withDuration:animations:)))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("OverrideSuperMethod.swift"))
            XCTAssertEqual(line, InternalErrorCanNotGetMethod)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try overrideSuperMethod(targetClass: OverrideOCObject.self, selector: NSSelectorFromString("superFuncWithoutObjc"))
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("OverrideSuperMethod.swift"))
            XCTAssertEqual(line, InternalErrorCanNotGetMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(debug_overrideMethodContextCount(), contextCount)
    }
    
    // MARK: Right cases
    
    func testOverrideSuccess() {
        let targetClass = OverrideOCObject.self
        let selector = #selector(OverrideOCObject.superFunc(arg:))
        
        // beginning
        let contextCount = debug_overrideMethodContextCount()
        guard let methodChild = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSuper = class_getInstanceMethod(OverrideSuperOCObject.self, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(methodChild, methodSuper)
        
        let object = OverrideOCObject()
        let result = object.superFunc(arg: [])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.first! == OverrideSuperOCObject.self)
        
        // added method
        do {
            try overrideSuperMethod(targetClass: targetClass, selector: selector)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(debug_overrideMethodContextCount(), contextCount + 1)
        
        guard let methodChildAfter = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertNotEqual(methodChildAfter, methodSuper)
        
        let resultAfter = object.superFunc(arg: [])
        XCTAssertEqual(resultAfter.count, 1)
        XCTAssertTrue(resultAfter.first! == OverrideSuperOCObject.self)
    }
    
    func testOverrideSuccessWithNonDynamicMethod() {
        let targetClass = OverrideOCObject.self
        let selector = #selector(OverrideOCObject.superFuncWithoutDynamic)
        
        // beginning
        let contextCount = debug_overrideMethodContextCount()
        guard let methodChild = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSuper = class_getInstanceMethod(OverrideSuperOCObject.self, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(methodChild, methodSuper)
        
        let object = OverrideOCObject()
        let result = object.superFunc(arg: [])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.first! == OverrideSuperOCObject.self)
        
        // added method
        do {
            try overrideSuperMethod(targetClass: targetClass, selector: selector)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(debug_overrideMethodContextCount(), contextCount + 1)
        
        guard let methodChildAfter = class_getInstanceMethod(targetClass, selector) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertNotEqual(methodChildAfter, methodSuper)
        
        let resultAfter = object.superFunc(arg: [])
        XCTAssertEqual(resultAfter.count, 1)
        XCTAssertTrue(resultAfter.first! == OverrideSuperOCObject.self)
    }
    
}
