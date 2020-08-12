//
//  SHMethodSignatureTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 7/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SHMethodSignatureTests: XCTestCase {
    
    func testInvalidClosure() {
        XCTAssertNil(SHMethodSignature.init(block: 1))
        XCTAssertNil(SHMethodSignature.init(block: {}))
        XCTAssertNil(SHMethodSignature.init(block: NSObject()))
        XCTAssertNil(SHMethodSignature.init(block: CGPoint.zero))
    }

    func testNoDynamicMethod() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noDynamicMethod)) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {} as @convention(block) () -> Void) else {
                XCTFail()
                return
            }
            
            let argumentTypesExpect: [String] = []
            let returnTypesExpect: String = "v"
            
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
            XCTAssertEqual(signatureMethod.returnType, returnTypesExpect)
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
            XCTAssertEqual(signatureClosure.returnType, returnTypesExpect)
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
        
        func testNoArgsNoReturnFunc() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.noArgsNoReturnFunc)) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {} as @convention(block) () -> Void) else {
                XCTFail()
                return
            }
            
            let argumentTypesExpect: [String] = []
            let returnTypesExpect: String = "v"
            
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
            XCTAssertEqual(signatureMethod.returnType, returnTypesExpect)
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
            XCTAssertEqual(signatureClosure.returnType, returnTypesExpect)
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
        
        func testSimpleSignature() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:))) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _  in
                } as @convention(block) (CChar, CInt, Int, CShort, CLong, CLongLong, CUnsignedChar, CUnsignedInt, UInt, CUnsignedShort, CUnsignedLong, CUnsignedLongLong, CFloat, Float, CDouble, Double, CBool, Bool, UnsafePointer<CChar>, AnyObject, AnyClass, Selector) -> Void) else {
                    XCTFail()
                    return
            }
            
            let argumentTypesExpect: [String] = ["c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "B", "B", "r*", "@", "#", ":"]
            let returnTypesExpect: String = "v"
            
            // If test error here, and you get ["@", ":", "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "c", "c", "r*", "@", "#", ":"]. please make sure the testing device is iPhone, not Mac.
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
            XCTAssertEqual(signatureMethod.returnType, returnTypesExpect)
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
            XCTAssertEqual(signatureClosure.returnType, returnTypesExpect)
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
        
        func testStructSignature() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testStructSignature(point:rect:))) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {_, _ in } as @convention(block) (CGPoint, CGRect) -> Void) else {
                XCTFail()
                return
            }
            
            let argumentTypesExpect: [String] = ["{CGPoint=dd}", "{CGRect={CGPoint=dd}{CGSize=dd}}"]
            let returnTypesExpect: String = "v"
            
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
            XCTAssertEqual(signatureMethod.returnType, returnTypesExpect)
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
            XCTAssertEqual(signatureClosure.returnType, returnTypesExpect)
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
        
        func testArraySignature() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:))) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {_, _, _ in } as @convention(block) ([Any], [Int], [CGRect]) -> Void) else {
                XCTFail()
                return
            }
            
            let argumentTypesExpect: [String] = ["@", "@", "@"]
            let returnTypesExpect: String = "v"
            
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
            XCTAssertEqual(signatureMethod.returnType, returnTypesExpect)
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
            XCTAssertEqual(signatureClosure.returnType, returnTypesExpect)
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
        
        func testDictionarySignature() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:))) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {_, _, _ in } as @convention(block) ([String: Any], [String: Int], [String: CGRect]) -> Void) else {
                XCTFail()
                return
            }
            
            let argumentTypesExpect: [String] = ["@", "@", "@"]
            let returnTypesExpect: String = "v"
            
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + argumentTypesExpect)
            XCTAssertEqual(signatureMethod.returnType, returnTypesExpect)
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + argumentTypesExpect)
            XCTAssertEqual(signatureClosure.returnType, returnTypesExpect)
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
        
        func testClosureSignature() {
            guard let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testClosureSignature(closure1:closure2:closure3:))) else {
                XCTFail()
                return
            }
            guard let signatureMethod = SHMethodSignature.init(method: method) else {
                XCTFail()
                return
            }
            guard let signatureClosure = SHMethodSignature.init(block: {_, _, _ in
                return {_, _ in
                    return NSObject()
                }
                } as @convention(block) (() -> Void, (Int, AnyObject) -> Int, (Int, AnyObject) -> AnyObject) -> (Int, AnyObject) -> AnyObject) else {
                    XCTFail()
                    return
            }
                        
            XCTAssertEqual(signatureMethod.argumentTypes, argumentTypesMethodPrefix + ["@?", "@?", "@?"])
            XCTAssertEqual(signatureMethod.returnType, "@?")
            XCTAssertEqual(signatureClosure.argumentTypes, argumentTypesClosurePrefix + ["@?<v@?>", "@?<q@?q@>", "@?<@@?q@>"])
            XCTAssertEqual(signatureClosure.returnType, "@?<@@?q@>")
            XCTAssertTrue(isSHMethodSignatureMatch(signature: signatureMethod, methodSignatureFromClosure: signatureClosure))
        }
    
    // MARK: utilities
    
    func isSHMethodSignatureMatch(signature: SHMethodSignature, methodSignatureFromClosure: SHMethodSignature) -> Bool {
        guard methodSignatureFromClosure.returnType.range(of: self.regex(prefix: signature.returnType), options: .regularExpression) != nil else {
                return false
        }
        let selfBusinessArgumentTypes = { () -> [String] in
            var argumentTypes = signature.argumentTypes
            argumentTypes.removeFirst(2)
            return argumentTypes
        }()
        
        let otherBusinessArgumentTypes = { () -> [String] in
            var argumentTypes = methodSignatureFromClosure.argumentTypes
            argumentTypes.removeFirst()
            return argumentTypes
        }()
        
        return otherBusinessArgumentTypes.elementsEqual(selfBusinessArgumentTypes) { (left, right) -> Bool in
            return left.range(of: self.regex(prefix: right), options: .regularExpression) != nil
        }
    }
    
    func regex(prefix: String) -> String {
        let partialRegex = prefix.map({
            var character = String($0)
            if character.range(of: "^\\W$", options: .regularExpression) != nil {
                character = "\\" + character
            }
            return character
        }).joined()
        return "^\(partialRegex)(\\<.+\\>)?$"
    }
    
}
