//
//  TestObject.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 24/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit

class SuperObject {
    @objc dynamic func superFunc(arg: [AnyClass]) -> [AnyClass] {
        var arg = arg
        arg.append(SuperObject.self)
        return arg
    }
}

class TestObject: SuperObject {
    
    var deinitExecution: (() -> Void)?
    
    deinit {
        deinitExecution?()
    }
    
    // Instance method
    func swiftMethod() {
        
    }
    
    @objc func noDynamicMethod() {
        
    }
    
    dynamic func noObjcMethod() {
        
    }
    
    @objc dynamic func noArgsNoReturnFunc() {
        
    }
    
    @objc dynamic func sumFunc(a: Int, b: Int) -> Int {
        return a + b
    }
    
    @objc dynamic func execute(closure: () -> Void) {
        closure()
    }
    
    @objc dynamic func generateView(backgroundColor: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = backgroundColor
        return view
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
        selector: Selector) {
        
    }
    
    @objc dynamic func testStructSignature(
        point: CGPoint,
        rect: CGRect ) {
        
    }
    
    @objc dynamic func testArraySignature(
        arrayAny: [Any],
        arrayInt: [Int],
        arrayStruct: [CGRect]
    ) {
        
    }
    
    @objc dynamic func testDictionarySignature(
        dictionaryAny: [String: Any],
        dictionaryInt: [String: Int],
        dictionaryStruct: [String: CGRect]
    ) {
        
    }
    
    @objc dynamic func testClosureSignature(
        closure1: () -> Void,
        closure2: (Int, AnyObject) -> Int,
        closure3: (Int, AnyObject) -> AnyObject
    ) -> (Int, AnyObject) -> AnyObject {
        return { i, obj in
            return NSObject()
        }
    }
    
    @objc dynamic func testPointerSignature(
        pointerInt: UnsafePointer<Int>,
        pointerChar: UnsafePointer<CChar>,
        pointerObj: UnsafePointer<AnyObject>,
        pointerStruct: UnsafePointer<CGRect>
    ) -> UnsafeMutablePointer<@convention(block) () -> Void> {
        var closure = {} as @convention(block) () -> Void
        return UnsafeMutablePointer(&closure)
    }
    
    // MARK: Class method
    
    class func classMethodSwiftMethod() {
        
    }
    
    @objc class func classMethodNoDynamicMethod() {
        
    }
    
    dynamic class func classMethodNoObjcMethod() {
        
    }
    
    @objc dynamic class func classMethodNoArgsNoReturnFunc() {
        
    }
    
    @objc dynamic class func classMethodSumFunc(a: Int, b: Int) -> Int {
        return a + b
    }
    
    @objc dynamic class func classMethodExecute(closure: () -> Void) {
        closure()
    }
    
    // signature
    @objc dynamic class func classMethodTestSimpleSignature(
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
        selector: Selector) {
        
    }
    
    @objc dynamic class func classMethodTestStructSignature(
        point: CGPoint,
        rect: CGRect ) {
        
    }
    
    @objc dynamic class func classMethodTestArraySignature(
        arrayAny: [Any],
        arrayInt: [Int],
        arrayStruct: [CGRect]
    ) {
        
    }
    
    @objc dynamic class func classMethodTestDictionarySignature(
        dictionaryAny: [String: Any],
        dictionaryInt: [String: Int],
        dictionaryStruct: [String: CGRect]
    ) {
        
    }
    
    @objc dynamic class func classMethodTestClosureSignature(
        closure1: () -> Void,
        closure2: (Int, AnyObject) -> Int,
        closure3: (Int, AnyObject) -> AnyObject
    ) -> (Int, AnyObject) -> AnyObject {
        return { i, obj in
            return NSObject()
        }
    }
    
    @objc dynamic class func classMethodTestPointerSignature(
        pointerInt: UnsafePointer<Int>,
        pointerChar: UnsafePointer<CChar>,
        pointerObj: UnsafePointer<AnyObject>,
        pointerStruct: UnsafePointer<CGRect>
    ) -> UnsafeMutablePointer<@convention(block) () -> Void> {
        var closure = {} as @convention(block) () -> Void
        return UnsafeMutablePointer(&closure)
    }
    
}
