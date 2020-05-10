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
        XCTAssertNil(Signature.init(closure: 1 as AnyObject))
        XCTAssertNil(Signature.init(closure: {} as AnyObject))
        XCTAssertNil(Signature.init(closure: NSObject()))
        XCTAssertNil(Signature.init(closure: CGPoint.zero as AnyObject))
        XCTAssertNil(Signature.init(closure: PureSwift()))
    }
    
    func testNoDynamicMethod() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noDynamicMethod)) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {} as @convention(block) () -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testNoArgsNoReturnFunc() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noArgsNoReturnFunc)) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {} as @convention(block) () -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testSimpleSignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _  in
            } as @convention(block) (CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void as AnyObject) else {
                XCTAssertTrue(false)
                return
        }
        
        let argumentTypesExpect: [String] = ["c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "B", "B", "r*", objectSignature, "#", selectoreSignature]
        let returnTypesExpect: String = voidSignature
        
        // If test error here, and you get [objectSignature, selectoreSignature, "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "c", "c", "r*", objectSignature, "#", selectoreSignature]. please make sure the testing device is iPhone, not Mac.
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testStructSignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testStructSignature(point:rect:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _ in } as @convention(block) (CGPoint, CGRect) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = ["{CGPoint=dd}", "{CGRect={CGPoint=dd}{CGSize=dd}}"]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testArraySignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _ in } as @convention(block) ([Any], [Int], [CGRect]) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testDictionarySignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _ in } as @convention(block) ([String: Any], [String: Int], [String: CGRect]) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testClosureSignature() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testClosureSignature(closure1:closure2:closure3:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _ in
            } as @convention(block) (() -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> Void as AnyObject) else {
                XCTAssertTrue(false)
                return
        }
        
        let argumentTypesExpect: [String] = [blockSignature, blockSignature, blockSignature]
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, blockSignature)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, voidSignature)
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    // MARK: instead
    
    func testNoDynamicMethodForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noDynamicMethod)) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_ in } as @convention(block) (() -> Void) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testNoArgsNoReturnFuncForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noArgsNoReturnFunc)) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_ in } as @convention(block) (() -> Void) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = []
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testSimpleSignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _  in
            } as @convention(block) ((CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void, CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void as AnyObject) else {
                XCTAssertTrue(false)
                return
        }
        
        let argumentTypesExpect: [String] = ["c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "B", "B", "r*", objectSignature, "#", selectoreSignature]
        let returnTypesExpect: String = voidSignature
        
        // If test error here, and you get [objectSignature, selectoreSignature, "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "c", "c", "r*", objectSignature, "#", selectoreSignature]. please make sure the testing device is iPhone, not Mac.
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testStructSignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testStructSignature(point:rect:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _ in } as @convention(block) ((CGPoint, CGRect) -> Void, CGPoint, CGRect) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = ["{CGPoint=dd}", "{CGRect={CGPoint=dd}{CGSize=dd}}"]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testArraySignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _, _ in } as @convention(block) (([Any], [Int], [CGRect]) -> Void, [Any], [Int], [CGRect]) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testDictionarySignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _, _ in } as @convention(block) (([String: Any], [String: Int], [String: CGRect]) -> Void, [String: Any], [String: Int], [String: CGRect]) -> Void as AnyObject) else {
            XCTAssertTrue(false)
            return
        }
        
        let argumentTypesExpect: [String] = [objectSignature, objectSignature, objectSignature]
        let returnTypesExpect: String = voidSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
    
    func testClosureSignatureForInstead() {
        guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testClosureSignature(closure1:closure2:closure3:))) else {
            XCTAssertTrue(false)
            return
        }
        guard let methodSignature = Signature.init(method: method) else {
            XCTAssertTrue(false)
            return
        }
        guard let closureSignature = Signature.init(closure: {_, _, _, _ in
            return {_, _ in
                return NSObject()
            }
            } as @convention(block) ((() -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> (Int, AnyObject) -> AnyObject, () -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> (Int, AnyObject) -> AnyObject as AnyObject) else {
                XCTAssertTrue(false)
                return
        }
        
        let argumentTypesExpect: [String] = [blockSignature, blockSignature, blockSignature]
        let returnTypesExpect: String = blockSignature
        
        XCTAssertEqual(methodSignature.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
        XCTAssertEqual(methodSignature.returnType, returnTypesExpect)
        XCTAssertEqual(closureSignature.argumentTypes, argumentTypesClosurePrefixForInstead + argumentTypesExpect)
        XCTAssertEqual(closureSignature.returnType, returnTypesExpect)
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .before))
        XCTAssertThrowsError(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .after))
        XCTAssertNoThrow(try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: .instead))
    }
}
