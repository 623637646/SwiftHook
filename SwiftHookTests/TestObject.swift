//
//  TestObject.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 24/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit

class SuperObject: NSObject {
    @objc dynamic func superFunc() {
        
    }
}

class TestObject: SuperObject {
    
    @objc dynamic func noArgsNoReturnFunc() {
        print("run \(#function)")
    }
    
    @objc dynamic func sumFunc(a: Int, b: Int) -> Int {
        print("run \(#function)")
        return a + b
    }
    
    // signature
    @objc dynamic func testSimpleSignature(
        char: CChar,
        int: CInt,
        swiftInt: Int,
        short: CShort,
        long: CLong,
        longlong: CLongLong,
        unsignedChar: CUnsignedChar,
        unsignedInt: CUnsignedInt,
        swiftUnsignedInt: UInt,
        unsignedshort: CUnsignedShort,
        unsignedLong: CUnsignedLong,
        unsignedLongLong: CUnsignedLongLong,
        float: CFloat,
        swiftFloat: Float,
        double: CDouble,
        swiftDouble: Double,
        bool: CBool,
        swiftBool: Bool,
        characterString: UnsafePointer<CChar>,
        object: AnyObject,
        class: AnyClass,
        selector: Selector) -> Void {
        print("run \(#function)")
    }
    
    @objc dynamic func testStructSignature(
        point: CGPoint,
        rect: CGRect ) -> Void {
        print("run \(#function)")
    }
    
    @objc dynamic func testArraySignature(
        arrayAny: [Any],
        arrayInt: [Int],
        arrayStruct: [CGRect]
    ) -> Void {
        print("run \(#function)")
    }
    
    @objc dynamic func testDictionarySignature(
        dictionaryAny: [String: Any],
        dictionaryInt: [String: Int],
        dictionaryStruct: [String: CGRect]
    ) -> Void {
        print("run \(#function)")
    }
    
    @objc dynamic func testBlockSignature(
        block1: () -> (),
        block2: (Int, AnyObject) -> Int,
        block4: (Int, AnyObject) -> AnyObject
    ) -> (Int, AnyObject) -> AnyObject {
        print("run \(#function)")
        return { i, obj in
            return NSObject()
        }
    }
}
