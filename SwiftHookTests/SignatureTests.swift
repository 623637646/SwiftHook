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
        XCTAssertEqual(signature!.argumentTypes, [])
    }
    
    func testSimpleSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, [])
    }
    
    func testStructSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testStructSignature(point:rect:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, [])
    }
    
    func testArraySignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testArraySignature(arrayAny:arrayInt:arrayStruct:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, [])
    }
    
    func testDictionarySignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testDictionarySignature(dictionaryAny:dictionaryInt:dictionaryStruct:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, [])
    }
    
    func testBlockSignature() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.testBlockSignature(block1:block2:block4:)))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, [])
    }

}
