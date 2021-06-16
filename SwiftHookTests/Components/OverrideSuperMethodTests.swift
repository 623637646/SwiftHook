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
    
    let InternalExistingMethod = 49
    let InternalErrorCanNotGetMethod = 55
    
    // MARK: Wrong cases
    
    func testSelfExistingMethod() {
        let contextCount = debug_overrideMethodContextCount()
        do {
            try overrideSuperMethod(targetClass: OverrideOCObject.self, selector: #selector(OverrideOCObject.selfFunc))
            XCTFail()
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
            XCTFail()
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("OverrideSuperMethod.swift"))
            XCTAssertEqual(line, InternalErrorCanNotGetMethod)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try overrideSuperMethod(targetClass: OverrideOCObject.self, selector: NSSelectorFromString("superFuncWithoutObjc"))
            XCTFail()
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
            XCTFail()
            return
        }
        guard let methodSuper = class_getInstanceMethod(OverrideSuperOCObject.self, selector) else {
            XCTFail()
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
            XCTFail()
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
            XCTFail()
            return
        }
        guard let methodSuper = class_getInstanceMethod(OverrideSuperOCObject.self, selector) else {
            XCTFail()
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
            XCTFail()
            return
        }
        XCTAssertNotEqual(methodChildAfter, methodSuper)
        
        let resultAfter = object.superFunc(arg: [])
        XCTAssertEqual(resultAfter.count, 1)
        XCTAssertTrue(resultAfter.first! == OverrideSuperOCObject.self)
    }
    
    func test_overrideMethodContext_after_instance_deinit() throws {
        class MySuperObject {
            @objc dynamic func myMethod() {
            }
        }
        class MyObject: MySuperObject {
            
        }
        
        // before
        let countBefore = debug_overrideMethodContextCount()
        XCTAssertNil(getMethodWithoutSearchingSuperClasses(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod)))
        
        var token: HookToken!
        var dynamicClass: AnyClass!
        try autoreleasepool {
            // hook
            let object = MyObject.init()
            token = try hookAfter(object: object, selector: #selector(MySuperObject.myMethod), closure: {
                
            }) as? HookToken
            dynamicClass = object_getClass(object)
            
            // check
            XCTAssertNil(getMethodWithoutSearchingSuperClasses(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod)))
            XCTAssertNotNil(getMethodWithoutSearchingSuperClasses(targetClass: dynamicClass, selector: #selector(MySuperObject.myMethod)))
            XCTAssertEqual(debug_overrideMethodContextCount(), countBefore + 2) // This should be 2 because first is method "myMethod", The second is method "class"
        }
        
        XCTAssertNotNil(token)
        XCTAssertNotNil(token.hookContext)
        XCTAssertNil(token.hookClosure)
        XCTAssertNil(token.hookObject)
        XCTAssertEqual(token.mode, .after)
        
        XCTAssertNil(getMethodWithoutSearchingSuperClasses(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod)))
        XCTAssertNotNil(getMethodWithoutSearchingSuperClasses(targetClass: dynamicClass, selector: #selector(MySuperObject.myMethod)))
        XCTAssertEqual(debug_overrideMethodContextCount(), countBefore + 2)
        
        XCTAssertNil(try internalCancelHook(token: token))
    }
    
    func test_overrideMethodContext_after_hook_cancellation() throws {
        class MySuperObject {
            @objc dynamic func myMethod() {
            }
        }
        class MyObject: MySuperObject {
            
        }
        
        // before
        let countBefore = debug_overrideMethodContextCount()
        XCTAssertNil(getMethodWithoutSearchingSuperClasses(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod)))
        
        // hook
        let token: HookToken! = try hookAfter(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod), closure: {
            
        }) as? HookToken
        
        // check
        XCTAssertNotNil(getMethodWithoutSearchingSuperClasses(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod)))
        XCTAssertEqual(debug_overrideMethodContextCount(), countBefore + 1)
        XCTAssertNotNil(token)
        XCTAssertNotNil(token.hookContext)
        XCTAssertNotNil(token.hookClosure)
        XCTAssertNil(token.hookObject)
        XCTAssertEqual(token.mode, .after)
        
        // cancel
        XCTAssertEqual(try internalCancelHook(token: token), true)
        
        // check
        XCTAssertNotNil(getMethodWithoutSearchingSuperClasses(targetClass: MyObject.self, selector: #selector(MySuperObject.myMethod)))
        XCTAssertEqual(debug_overrideMethodContextCount(), countBefore + 1)
    }
    
}
