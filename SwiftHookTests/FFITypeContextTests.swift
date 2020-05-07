//
//  FFITypeContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 1/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class FFITypeContextTests: XCTestCase {
    
    func testVoid() {
        let block: @convention(block) () -> Void = {}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_void))
    }
    
    func testUInt8() {
        let block: @convention(block) () -> UInt8 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_uint8))
    }
    
    func testInt8() {
        let block: @convention(block) () -> Int8 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_sint8))
    }
    
    func testUInt16() {
        let block: @convention(block) () -> UInt16 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_uint16))
    }
    
    func testInt16() {
        let block: @convention(block) () -> Int16 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_sint16))
    }
    
    func testUInt32() {
        let block: @convention(block) () -> UInt32 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_uint32))
    }
    
    func testInt32() {
        let block: @convention(block) () -> Int32 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_sint32))
    }
    
    func testUInt64() {
        let block: @convention(block) () -> UInt64 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_uint64))
    }
    
    func testInt64() {
        let block: @convention(block) () -> Int64 = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_sint64))
    }
    
    func testFloat() {
        let block: @convention(block) () -> Float = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_float))
    }
    
    func testCGFloat() {
        let block: @convention(block) () -> CGFloat = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_double))
    }
    
    func testDouble() {
        let block: @convention(block) () -> Double = {0}
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_double))
    }
    
    func testPointerDouble() {
        let block: @convention(block) () -> UnsafePointer<Double> = {
            var d: Double = 0
            return UnsafePointer<Double>(&d)
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_pointer))
    }
    
    func testPointerObject() {
        let block: @convention(block) () -> NSObject = {
            return NSObject()
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_pointer))
    }
    
    func testBool() {
        let block: @convention(block) () -> Bool = {
            return false
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_sint8))
    }
    
    func testClass() {
        let block: @convention(block) () -> AnyClass = {
            return Self.self
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_pointer))
    }
    
    func testSEL() {
        let block: @convention(block) () -> Selector = {
            return #function
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_pointer))
    }
    
    func testVoidAsterisk () {
        let block: @convention(block) () -> Any = {
            return 0
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(typeContext.ffiType, UnsafeMutablePointer(&ffi_type_pointer))
    }
    
    func testStructCGPoint () {
        let block: @convention(block) () -> CGPoint = {
            return CGPoint.zero
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        structTestHelper(signature: [UnsafeMutablePointer(&ffi_type_double),
                                     UnsafeMutablePointer(&ffi_type_double)],
                         ffiType: typeContext.ffiType.pointee)
    }
    
    func testStructCGRect () {
        let block: @convention(block) () -> CGRect = {
            return CGRect.zero
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        structTestHelper(signature: [
            [UnsafeMutablePointer(&ffi_type_double),
             UnsafeMutablePointer(&ffi_type_double)],
            [UnsafeMutablePointer(&ffi_type_double),
             UnsafeMutablePointer(&ffi_type_double)]
            ],
                         ffiType: typeContext.ffiType.pointee)
    }
    
    func testComplexityStruct () {
        let block: @convention(block) () -> ComplexityStruct = {
            return ComplexityStruct.init()
        }
        guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
            XCTAssertTrue(false)
            return
        }
        guard let typeContext = SHFFITypeContext.init(typeEncoding: typeEncoding) else {
            XCTAssertTrue(false)
            return
        }
        structTestHelper(signature: [
            UnsafeMutablePointer(&ffi_type_sint32),
            [
                UnsafeMutablePointer(&ffi_type_double),
                UnsafeMutablePointer(&ffi_type_double)
            ],
            [
                [
                    UnsafeMutablePointer(&ffi_type_double),
                    UnsafeMutablePointer(&ffi_type_double)
                ],
                [
                    UnsafeMutablePointer(&ffi_type_double),
                    UnsafeMutablePointer(&ffi_type_double)
                ]
            ],
            [
                UnsafeMutablePointer(&ffi_type_double),
                [
                    UnsafeMutablePointer(&ffi_type_pointer),
                    []
                ]
            ]
        ], ffiType: typeContext.ffiType.pointee)
    }
    
    func testReusedContext() {
        var blocks = [Any]()
        blocks.append(({} as @convention(block) () -> Void))
        blocks.append(({0} as @convention(block) () -> UInt8))
        blocks.append(({0} as @convention(block) () -> Int8))
        blocks.append(({0} as @convention(block) () -> UInt16))
        blocks.append(({0} as @convention(block) () -> Int16))
        blocks.append(({0} as @convention(block) () -> UInt32))
        blocks.append(({0} as @convention(block) () -> Int32))
        blocks.append(({0} as @convention(block) () -> UInt64))
        blocks.append(({0} as @convention(block) () -> Int64))
        blocks.append(({0} as @convention(block) () -> Float))
        blocks.append(({0} as @convention(block) () -> CGFloat))
        blocks.append(({0} as @convention(block) () -> Double))
        blocks.append(({
            var d: Double = 0
            return UnsafePointer<Double>(&d)
            } as @convention(block) () -> UnsafePointer<Double>))
        blocks.append(({NSObject()} as @convention(block) () -> NSObject))
        blocks.append(({false} as @convention(block) () -> Bool))
        blocks.append(({Self.self} as @convention(block) () -> AnyClass))
        blocks.append(({#function} as @convention(block) () -> Selector))
        blocks.append(({0} as @convention(block) () -> Any))
        blocks.forEach { (block) in
            guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
                XCTAssertTrue(false)
                return
            }
            XCTAssertTrue(SHFFITypeContext.init(typeEncoding: typeEncoding) ==
                SHFFITypeContext.init(typeEncoding: typeEncoding))
        }
        blocks.removeAll()
        blocks.append(({CGPoint.zero} as @convention(block) () -> CGPoint))
        blocks.append(({CGRect.zero} as @convention(block) () -> CGRect))
        blocks.append(({ComplexityStruct.init()} as @convention(block) () -> ComplexityStruct))
        blocks.forEach { (block) in
            guard let typeEncoding = self.getReturnTypeEncoding(block: block) else {
                XCTAssertTrue(false)
                return
            }
            XCTAssertTrue(SHFFITypeContext.init(typeEncoding: typeEncoding) !=
                SHFFITypeContext.init(typeEncoding: typeEncoding))
        }
    }
    
    // MARK: Memory test
    
    func testMemory() {
//        while true {
//            autoreleasepool {
//                testVoid()
//                testInt8()
//                testPointerObject()
//                testPointerDouble()
//                testVoidAsterisk()
//                testStructCGRect()
//                testComplexityStruct()
//            }
//        }
    }
    
    // MARK: utilities
    
    func getReturnTypeEncoding(block: Any) -> String? {
        let methodSignature = SHMethodSignature.init(block: block)
        return methodSignature?.returnType
    }
    
    func structTestHelper(signature: [Any], ffiType: ffi_type) {
        XCTAssertEqual(ffiType.type, UInt16(FFI_TYPE_STRUCT))
        let bufferPointer = UnsafeMutableBufferPointer(start: ffiType.elements, count: signature.count + 1)
        guard signature.count != 0 else {
            XCTAssertNil(bufferPointer[0])
            return
        }
        for index in 0 ... signature.count - 1 {
            let currentSignature = signature[index]
            guard let currentPointer = bufferPointer[index] else {
                XCTAssertTrue(false)
                break
            }
            if let normalSignature = currentSignature as? UnsafeMutablePointer<ffi_type> {
                XCTAssertEqual(normalSignature, currentPointer)
            } else if let elementsSignature = currentSignature as? [Any] {
                structTestHelper(signature: elementsSignature, ffiType: currentPointer.pointee)
            } else {
                XCTAssertTrue(false)
            }
        }
        XCTAssertNil(bufferPointer[signature.count])
    }
    
}
