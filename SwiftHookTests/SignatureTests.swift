//
//  SignatureTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SignatureTests: XCTestCase {

    func testNoArgsNoReturnFunc() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, ["@", ":"])
        XCTAssertEqual(signature!.returnType, "v")
    }
    
    func testSimpleSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:)))
        XCTAssertNotNil(signature)
        // If test error here, and you get ["@", ":", "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "c", "c", "r*", "@", "#", ":"]. please make sure the testing device is iPhone, not Mac.
        XCTAssertEqual(signature!.argumentTypes, ["@", ":", "c", "i", "q", "s", "q", "q", "C", "I", "Q", "S", "Q", "Q", "f", "f", "d", "d", "B", "B", "r*", "@", "#", ":"])
        XCTAssertEqual(signature!.returnType, "v")
    }
    
    func testStructSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testStructSignature(point:rect:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, ["@", ":", "{CGPoint=dd}", "{CGRect={CGPoint=dd}{CGSize=dd}}"])
        XCTAssertEqual(signature!.returnType, "v")
    }
    
    func testArraySignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, ["@", ":", "@", "@", "@"])
        XCTAssertEqual(signature!.returnType, "v")
    }
    
    func testDictionarySignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, ["@", ":", "@", "@", "@"])
        XCTAssertEqual(signature!.returnType, "v")
    }
    
    func testBlockSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testBlockSignature(block1:block2:block4:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, ["@", ":", "@?", "@?", "@?"])
        XCTAssertEqual(signature!.returnType, "@?")
    }

    func testPointerSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testPointerSignature(pointerInt:pointerChar:pointerObj:pointerStruct:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, ["@", ":", "r^q", "r*", "r^@", "r^{CGRect={CGPoint=dd}{CGSize=dd}}"])
        XCTAssertEqual(signature!.returnType, "^@?")
    }
}
