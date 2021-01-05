//
//  SignatureTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

let blockSignature = "@?"
let objectSignature = "@"
let selectoreSignature = ":"
let voidSignature = "v"

let argumentTypesMethodPrefix = [objectSignature, selectoreSignature]
let argumentTypesClosurePrefix = [blockSignature]
let argumentTypesClosurePrefixForInstead = [blockSignature, blockSignature]

class SignatureTests: XCTestCase {
    
    // MARK: before & after
    
    func testInvalidClosure() {
        do {
            _ = try Signature.init(closure: 1 as AnyObject)
            _ = try Signature.init(closure: {} as AnyObject)
            _ = try Signature.init(closure: NSObject())
            _ = try Signature.init(closure: CGPoint.zero as AnyObject)
        } catch SwiftHookError.wrongTypeForHookClosure {
        } catch {
            XCTFail()
        }
    }
    
    func testNoDynamicMethod() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noDynamicMethod)) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {} as @convention(block) () -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testNoArgsNoReturnFunc() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noArgsNoReturnFunc)) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {} as @convention(block) () -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testSimpleSignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _  in
        } as @convention(block) (CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = ["c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "B", "B", "r*", objectSignature, "#", selectoreSignature]
        let returnTypesExpect: String = voidSignature
        
        // If test error here, and you get [objectSignature, selectoreSignature, "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "c", "c", "r*", objectSignature, "#", selectoreSignature]. please make sure the testing device is iPhone, not Mac.
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testStructSignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testStructSignature(point:rect:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _ in } as @convention(block) (CGPoint, CGRect) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = ["{CGPoint=dd}", "{CGRect={CGPoint=dd}{CGSize=dd}}"]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testArraySignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _ in } as @convention(block) ([Any], [Int], [CGRect]) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testDictionarySignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _ in } as @convention(block) ([String: Any], [String: Int], [String: CGRect]) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testClosureSignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testClosureSignature(closure1:closure2:closure3:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _ in
        } as @convention(block) (() -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = [blockSignature, blockSignature, blockSignature]
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, blockSignature)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, voidSignature)
    }
    
    func testPointer() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testPointerSignature(pointerInt:pointerChar:pointerObj:pointerStruct:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _ in
        } as @convention(block) (UnsafePointer<Int>, UnsafePointer<CChar>, UnsafePointer<AnyObject>, UnsafePointer<CGRect>) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = ["r^q", "r*", "r^@", "r^{CGRect={CGPoint=dd}{CGSize=dd}}"]
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, "^" + blockSignature)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, voidSignature)
    }
    
    // MARK: instead
    
    func testNoDynamicMethodForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noDynamicMethod)) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_ in } as @convention(block) (() -> Void) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testNoArgsNoReturnFuncForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noArgsNoReturnFunc)) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_ in } as @convention(block) (() -> Void) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testSimpleSignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _  in
        } as @convention(block) ((CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void, CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = ["c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "B", "B", "r*", objectSignature, "#", selectoreSignature]
        let returnTypesExpect: String = voidSignature
        
        // If test error here, and you get [objectSignature, selectoreSignature, "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "c", "c", "r*", objectSignature, "#", selectoreSignature]. please make sure the testing device is iPhone, not Mac.
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testStructSignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testStructSignature(point:rect:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _ in } as @convention(block) ((CGPoint, CGRect) -> Void, CGPoint, CGRect) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = ["{CGPoint=dd}", "{CGRect={CGPoint=dd}{CGSize=dd}}"]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testArraySignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _ in } as @convention(block) (([Any], [Int], [CGRect]) -> Void, [Any], [Int], [CGRect]) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testDictionarySignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _ in } as @convention(block) (([String: Any], [String: Int], [String: CGRect]) -> Void, [String: Any], [String: Int], [String: CGRect]) -> Void as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testClosureSignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testClosureSignature(closure1:closure2:closure3:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _ in
            return {_, _ in
                return NSObject()
            }
        } as @convention(block) ((() -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> (Int, AnyObject) -> AnyObject, () -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> (Int, AnyObject) -> AnyObject as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = [blockSignature, blockSignature, blockSignature]
        let returnTypesExpect: String = blockSignature
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func testPointerForInstead() {
        guard let method = class_getClassMethod(TestObject.self, #selector(TestObject.classMethodTestPointerSignature(pointerInt:pointerChar:pointerObj:pointerStruct:))) else {
            XCTFail()
            return
        }
        guard let methodSignature = try? Signature.init(method: method) else {
            XCTFail()
            return
        }
        guard let closureSignature = try? Signature.init(closure: {_, _, _, _, _ in
            return UnsafeMutablePointer<@convention(block) () -> Void>.init(nil)!
        } as @convention(block) ((UnsafePointer<Int>, UnsafePointer<CChar>, UnsafePointer<AnyObject>, UnsafePointer<CGRect>) -> UnsafeMutablePointer<@convention(block) () -> Void>, UnsafePointer<Int>, UnsafePointer<CChar>, UnsafePointer<AnyObject>, UnsafePointer<CGRect>) -> UnsafeMutablePointer<@convention(block) () -> Void> as AnyObject) else {
            XCTFail()
            return
        }
        
        let argumentTypesExpect: [String] = ["r^q", "r*", "r^@", "r^{CGRect={CGPoint=dd}{CGSize=dd}}"]
        let returnTypesExpect: String = "^@?"
        
        XCTAssertEqual(methodSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({ (value) -> String in
            return value.code
        }), argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func test_normal_cases() throws {
        class MyObject {
            @objc dynamic func myMethod(int: CInt,
                                        float: Float,
                                        floatPointer: UnsafePointer<CFloat>,
                                        char: CChar,
                                        charPointer: UnsafePointer<CChar>,
                                        bool: Bool,
                                        voidPointer1: OpaquePointer,
                                        voidPointer2: UnsafeRawPointer,
                                        voidPointer3: UnsafeMutableRawPointer,
                                        NSObjectPointer: UnsafePointer<NSObject>,
                                        NSObject: NSObject,
                                        NSObjectArray: [NSObject],
                                        NSErrorPointerPointer: UnsafePointer<UnsafePointer<NSError>>,
                                        intArray: [CInt],
                                        floatArray: [CFloat],
                                        struct: CGPoint
            ) {}
        }
        let methodSignature = try Signature.init(method: class_getInstanceMethod(MyObject.self, #selector(MyObject.myMethod(int:float:floatPointer:char:charPointer:bool:voidPointer1:voidPointer2:voidPointer3:NSObjectPointer:NSObject:NSObjectArray:NSErrorPointerPointer:intArray:floatArray:struct:)))!)
        let closureSignature = try Signature.init(closure: { _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ in } as @convention(block) (CInt, CFloat, UnsafePointer<CFloat>, CChar, UnsafePointer<CChar>, CBool, OpaquePointer, UnsafeRawPointer, UnsafeMutableRawPointer, UnsafePointer<NSObject>, NSObject, [NSObject], UnsafePointer<UnsafePointer<NSError>>, [CInt], [CFloat], CGPoint) -> Void as AnyObject)
        
        let argumentTypesExpect: [String] = ["i", "f", "r^f", "c", "r*", "B", "^v", "^v", "^v", "r^@", "@", "@", "r^^@", "@", "@", "{CGPoint=dd}"]
        let returnTypesExpect: String = "v"
        
        XCTAssertEqual(methodSignature.argumentTypes.map({$0.code}), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({$0.code}), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
    
    func test_const() throws {
        class MyObject {
            @objc dynamic func myMethod(p: UnsafePointer<CGRect>) -> UnsafePointer<CGRect>? {
                return nil
            }
        }
        let methodSignature = try Signature.init(method: class_getInstanceMethod(MyObject.self, #selector(MyObject.myMethod(p:)))!)
        let closureSignature = try Signature.init(closure: {_ in
            return nil
        } as @convention(block) (UnsafePointer<CGRect>) -> UnsafePointer<CGRect>? as AnyObject)
        
        let argumentTypesExpect: [String] = ["r^{CGRect={CGPoint=dd}{CGSize=dd}}"]
        let returnTypesExpect: String = "r^{CGRect={CGPoint=dd}{CGSize=dd}}"
        
        XCTAssertEqual(methodSignature.argumentTypes.map({$0.code}), argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType.code, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes.map({$0.code}), argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType.code, returnTypesExpect)
    }
}
