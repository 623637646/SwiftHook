//
//  MethodObjectAndSelectorTest.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 13/8/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class MethodObjectAndSelectorTest: XCTestCase {
    
    // MARK: - All Instances
    
    // MARK: Before
    
    func test_AllInstances_Before() {
        do {
            // hook
            let object = TestObject()
            let targetClass = TestObject.self
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            var run = false
            let closure = { [weak object, selector] obj, sel in
                run = true
                XCTAssertTrue(obj === object)
                XCTAssertTrue(sel == selector)
                } as @convention(block) (NSObject, Selector) -> Void
            let token = try hookBefore(targetClass: targetClass, selector: selector, closure: closure)
            
            // test hook
            object.noArgsNoReturnFunc()
            XCTAssertTrue(run)
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_AllInstances_Before_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            let closure = {_, _ in
                } as @convention(block) (Selector, NSObject) -> Void
            try hookBefore(targetClass: targetClass, selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be nil or `@:` or as the same as method's. The closure parameters type is `:@`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: After
    
    func test_AllInstances_After() {
        do {
            // hook
            let object = TestObject()
            let targetClass = TestObject.self
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            var run = false
            let closure = { [weak object, selector] obj, sel in
                run = true
                XCTAssertTrue(obj === object)
                XCTAssertTrue(sel == selector)
                } as @convention(block) (NSObject, Selector) -> Void
            let token = try hookAfter(targetClass: targetClass, selector: selector, closure: closure)
            
            // test hook
            object.noArgsNoReturnFunc()
            XCTAssertTrue(run)
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_AllInstances_After_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            let closure = {_, _ in
                } as @convention(block) (Selector, NSObject) -> Void
            try hookAfter(targetClass: targetClass, selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be nil or `@:` or as the same as method's. The closure parameters type is `:@`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Instead
    
    func test_AllInstances_Instead() {
        do {
            // hook
            let object = TestObject()
            let targetClass = TestObject.self
            let selector = #selector(TestObject.execute(closure:))
            var result = [Int]()
            let closure = {[weak object, selector] original, obj, sel, closure in
                XCTAssertTrue(obj === object)
                XCTAssertTrue(sel == selector)
                result.append(-1)
                original(obj, sel, closure)
                result.append(1)
                } as @convention(block) (@escaping (AnyObject, Selector, () -> Void) -> Void, AnyObject, Selector, () -> Void) -> Void
            let token = try hookInstead(targetClass: targetClass, selector: selector, closure: closure)
            
            // test hook
            object.execute {
                result.append(0)
            }
            XCTAssertEqual(result, [-1, 0, 1])
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_AllInstances_Instead_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            let closure = { _, _, _ in
                } as @convention(block) ((Selector, NSObject) -> Void, Selector, NSObject) -> Void
            try hookInstead(targetClass: targetClass, selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The parameters type of the original closure (the hook closure's first parameter) must be the same as the method's. The original closure parameters type is `:@`. But the method parameters type is `@:`. They are not the same. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_AllInstances_Instead_Changed() {
        do {
            // model
            let object = ObjectiveCTestObject()
            object.number = 1
            
            // test non-hook
            var result = object.getSelfNumberPlusCMD()
            XCTAssertEqual(result, "1+getSelfNumberPlusCMD")
            
            // hook
            let targetClass = ObjectiveCTestObject.self
            let selector = #selector(ObjectiveCTestObject.getSelfNumberPlusCMD)
            
            let closureBefore = {obj, sel in
                XCTAssertEqual(obj.number, 2)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.noArgsNoReturnFunc))
                } as @convention(block) (ObjectiveCTestObject, Selector) -> Void
            let tokenBefore = try hookBefore(targetClass: targetClass, selector: selector, closure: closureBefore)
            
            let closureAfter = {obj, sel in
                XCTAssertEqual(obj.number, 2)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.noArgsNoReturnFunc))
                } as @convention(block) (ObjectiveCTestObject, Selector) -> Void
            let tokenAfter = try hookAfter(targetClass: targetClass, selector: selector, closure: closureAfter)
            
            let closureInstead1 = {original, obj, sel in
                XCTAssertEqual(obj.number, 3)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.classNoArgsNoReturnFunc))
                let object = ObjectiveCTestObject()
                object.number = 2
                return original(object, #selector(ObjectiveCTestObject.noArgsNoReturnFunc))
                } as @convention(block) ((ObjectiveCTestObject, Selector) -> String, ObjectiveCTestObject, Selector) -> String
            let tokenInstead1 = try hookInstead(targetClass: targetClass, selector: selector, closure: closureInstead1)
            
            let closureInstead2 = {original, obj, sel in
                XCTAssertEqual(obj.number, 4)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.sumFunc(withA:b:)))
                let object = ObjectiveCTestObject()
                object.number = 3
                return original(object, #selector(ObjectiveCTestObject.classNoArgsNoReturnFunc))
                } as @convention(block) ((ObjectiveCTestObject, Selector) -> String, ObjectiveCTestObject, Selector) -> String
            let tokenInstead2 = try hookInstead(targetClass: targetClass, selector: selector, closure: closureInstead2)
            
            let closureInstead3 = {original, obj, sel in
                XCTAssertEqual(obj.number, 1)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.getSelfNumberPlusCMD))
                let object = ObjectiveCTestObject()
                object.number = 4
                return original(object, #selector(ObjectiveCTestObject.sumFunc(withA:b:)))
                } as @convention(block) ((ObjectiveCTestObject, Selector) -> String, ObjectiveCTestObject, Selector) -> String
            let tokenInstead3 = try hookInstead(targetClass: targetClass, selector: selector, closure: closureInstead3)
            
            // test hook
            result = object.getSelfNumberPlusCMD()
            XCTAssertEqual(result, "2+noArgsNoReturnFunc")
            
            // cancel
            tokenBefore.cancelHook()
            tokenAfter.cancelHook()
            tokenInstead1.cancelHook()
            tokenInstead2.cancelHook()
            tokenInstead3.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: - Class
    
    // MARK: Before
    
    func test_Class_Before() {
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.classMethodNoArgsNoReturnFunc)
            var run = false
            let closure = { obj, sel in
                run = true
                XCTAssertTrue(obj === targetClass)
                XCTAssertTrue(sel == selector)
                } as @convention(block) (NSObject, Selector) -> Void
            let token = try hookClassMethodBefore(targetClass: targetClass, selector: selector, closure: closure)
            
            // test hook
            TestObject.classMethodNoArgsNoReturnFunc()
            XCTAssertTrue(run)
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Class_Before_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.classMethodNoArgsNoReturnFunc)
            let closure = {_, _ in
                } as @convention(block) (Selector, NSObject) -> Void
            try hookClassMethodBefore(targetClass: targetClass, selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be nil or `@:` or as the same as method's. The closure parameters type is `:@`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: After
    
    func test_Class_After() {
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.classMethodNoArgsNoReturnFunc)
            var run = false
            let closure = { obj, sel in
                run = true
                XCTAssertTrue(obj === targetClass)
                XCTAssertTrue(sel == selector)
                } as @convention(block) (NSObject, Selector) -> Void
            let token = try hookClassMethodAfter(targetClass: targetClass, selector: selector, closure: closure)
            
            // test hook
            TestObject.classMethodNoArgsNoReturnFunc()
            XCTAssertTrue(run)
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Class_After_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.classMethodNoArgsNoReturnFunc)
            let closure = {_, _ in
                } as @convention(block) (Selector, NSObject) -> Void
            try hookClassMethodAfter(targetClass: targetClass, selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be nil or `@:` or as the same as method's. The closure parameters type is `:@`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Instead
    
    func test_Class_Instead() {
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.classMethodExecute(closure:))
            var result = [Int]()
            let closure = { original, obj, sel, closure in
                XCTAssertTrue(obj === targetClass)
                XCTAssertTrue(sel == selector)
                result.append(-1)
                original(obj, sel, closure)
                result.append(1)
                } as @convention(block) (@escaping (AnyObject, Selector, () -> Void) -> Void, AnyObject, Selector, () -> Void) -> Void
            let token = try hookClassMethodInstead(targetClass: targetClass, selector: selector, closure: closure)
            
            // test hook
            TestObject.classMethodExecute {
                result.append(0)
            }
            XCTAssertEqual(result, [-1, 0, 1])
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Class_Instead_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let targetClass = TestObject.self
            let selector = #selector(TestObject.classMethodNoArgsNoReturnFunc)
            let closure = { _, _, _ in
                } as @convention(block) ((Selector, NSObject) -> Void, Selector, NSObject) -> Void
            try hookClassMethodInstead(targetClass: targetClass, selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The parameters type of the original closure (the hook closure's first parameter) must be the same as the method's. The original closure parameters type is `:@`. But the method parameters type is `@:`. They are not the same. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: - Single Instance
    
    // MARK: Before
    
    func test_Single_Before() {
        do {
            // hook
            let object = TestObject()
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            var run = false
            let closure = { [weak object, selector] obj, sel in
                run = true
                XCTAssertTrue(obj === object)
                XCTAssertTrue(sel == selector)
                } as @convention(block) (NSObject, Selector) -> Void
            let token = try hookBefore(object: object, selector: selector, closure: closure)
            
            // test hook
            object.noArgsNoReturnFunc()
            XCTAssertTrue(run)
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Single_Before_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            let closure = {_, _ in
                } as @convention(block) (Selector, NSObject) -> Void
            try hookBefore(object: TestObject(), selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be nil or `@:` or as the same as method's. The closure parameters type is `:@`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: After
    
    func test_Single_After() {
        do {
            // hook
            let object = TestObject()
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            var run = false
            let closure = { [weak object, selector] obj, sel in
                run = true
                XCTAssertTrue(obj === object)
                XCTAssertTrue(sel == selector)
                } as @convention(block) (NSObject, Selector) -> Void
            let token = try hookAfter(object: object, selector: selector, closure: closure)
            
            // test hook
            object.noArgsNoReturnFunc()
            XCTAssertTrue(run)
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Single_After_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            let closure = {_, _ in
                } as @convention(block) (Selector, NSObject) -> Void
            try hookAfter(object: TestObject(), selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be nil or `@:` or as the same as method's. The closure parameters type is `:@`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Instead
    
    func test_Single_Instead() {
        do {
            // hook
            let object = TestObject()
            let selector = #selector(TestObject.execute(closure:))
            var result = [Int]()
            let closure = {[weak object, selector] original, obj, sel, closure in
                XCTAssertTrue(obj === object)
                XCTAssertTrue(sel == selector)
                result.append(-1)
                original(obj, sel, closure)
                result.append(1)
                } as @convention(block) (@escaping (AnyObject, Selector, () -> Void) -> Void, AnyObject, Selector, () -> Void) -> Void
            let token = try hookInstead(object: object, selector: selector, closure: closure)
            
            // test hook
            object.execute {
                result.append(0)
            }
            XCTAssertEqual(result, [-1, 0, 1])
            
            // cancel
            token.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Single_Instead_Parameters_Checking() {
        
        // Wrong order of Object and Selector
        do {
            // hook
            let selector = #selector(TestObject.noArgsNoReturnFunc)
            let closure = { _, _, _ in
                } as @convention(block) ((Selector, NSObject) -> Void, Selector, NSObject) -> Void
            try hookInstead(object: TestObject(), selector: selector, closure: closure)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The parameters type of the original closure (the hook closure's first parameter) must be the same as the method's. The original closure parameters type is `:@`. But the method parameters type is `@:`. They are not the same. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Single_Instead_Changed() {
        do {
            // model
            let object = ObjectiveCTestObject()
            object.number = 1
            
            // test non-hook
            var result = object.getSelfNumberPlusCMD()
            XCTAssertEqual(result, "1+getSelfNumberPlusCMD")
            
            // hook
            let selector = #selector(ObjectiveCTestObject.getSelfNumberPlusCMD)
            
            let closureBefore = {obj, sel in
                XCTAssertEqual(obj.number, 1)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.getSelfNumberPlusCMD))
                } as @convention(block) (ObjectiveCTestObject, Selector) -> Void
            let tokenBefore = try hookBefore(object: object, selector: selector, closure: closureBefore)
            
            let closureAfter = {obj, sel in
                XCTAssertEqual(obj.number, 3)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.classNoArgsNoReturnFunc))
                } as @convention(block) (ObjectiveCTestObject, Selector) -> Void
            let tokenAfter = try hookAfter(object: object, selector: selector, closure: closureAfter)
            
            let closure1 = {original, obj, sel in
                XCTAssertEqual(obj.number, 3)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.classNoArgsNoReturnFunc))
                let object = ObjectiveCTestObject()
                object.number = 2
                return original(object, #selector(ObjectiveCTestObject.noArgsNoReturnFunc))
                } as @convention(block) ((ObjectiveCTestObject, Selector) -> String, ObjectiveCTestObject, Selector) -> String
            let token1 = try hookInstead(object: object, selector: selector, closure: closure1)
            
            let closure2 = {original, obj, sel in
                XCTAssertEqual(obj.number, 1)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.sumFunc(withA:b:)))
                let object = ObjectiveCTestObject()
                object.number = 3
                return original(object, #selector(ObjectiveCTestObject.classNoArgsNoReturnFunc))
                } as @convention(block) ((ObjectiveCTestObject, Selector) -> String, ObjectiveCTestObject, Selector) -> String
            let token2 = try hookInstead(object: object, selector: selector, closure: closure2)
            
            let closure3 = {original, obj, sel in
                XCTAssertEqual(obj.number, 1)
                XCTAssertEqual(sel, #selector(ObjectiveCTestObject.getSelfNumberPlusCMD))
                return original(obj, #selector(ObjectiveCTestObject.sumFunc(withA:b:)))
                } as @convention(block) ((ObjectiveCTestObject, Selector) -> String, ObjectiveCTestObject, Selector) -> String
            let token3 = try hookInstead(object: object, selector: selector, closure: closure3)
            
            // test hook
            result = object.getSelfNumberPlusCMD()
            XCTAssertEqual(result, "3+classNoArgsNoReturnFunc")
            
            // cancel
            tokenBefore.cancelHook()
            tokenAfter.cancelHook()
            token1.cancelHook()
            token2.cancelHook()
            token3.cancelHook()
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_change_object() throws {
        class MyObject {
            @objc dynamic func myMethod() {
                
            }
        }
        
        let obj = MyObject.init()
        var array = [Int]()
        try hookBefore(object: obj, selector: #selector(MyObject.myMethod)) {
            array.append(2)
        }
        try hookInstead(object: obj, selector: #selector(MyObject.myMethod), closure: {original, _, sel in
            array.append(1)
            original(NSURLRequest.init(), sel)
            array.append(4)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        try hookAfter(object: obj, selector: #selector(MyObject.myMethod), closure: {
            array.append(3)
        })
        obj.myMethod()
        XCTAssertEqual(array, [1, 4])
    }
}
