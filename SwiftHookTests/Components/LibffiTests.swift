//
//  LibffiTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 26/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
import libffi_iOS

class LibffiTests: XCTestCase {
    
    func testLibffiCall() {
        var cif: ffi_cif = ffi_cif()
        let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
        defer { argumentTypes.deallocate() }
        argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[2] = UnsafeMutablePointer(&ffi_type_sint64)
        argumentTypes[3] = UnsafeMutablePointer(&ffi_type_sint64)
        let status_cif = withUnsafeMutablePointer(to: &cif) { (p) -> ffi_status in
            ffi_prep_cif(
                p,
                FFI_DEFAULT_ABI,
                4,
                UnsafeMutablePointer(&ffi_type_sint64),
                argumentTypes.baseAddress)
        }
        XCTAssertEqual(status_cif, FFI_OK)
        
        var obj = TestObject.init()
        var selector = #selector(TestObject.sumFunc(a:b:))
        let imp = class_getMethodImplementation(TestObject.self, selector)
        var arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
        var arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
        var returnValue: Int = 0
        let arguments = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>.allocate(capacity: 4)
        defer { arguments.deallocate() }
        arguments[0] = withUnsafeMutablePointer(to: &obj, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        arguments[1] = withUnsafeMutablePointer(to: &selector, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        arguments[2] = withUnsafeMutablePointer(to: &arg1, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        arguments[3] = withUnsafeMutablePointer(to: &arg2, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        withUnsafeMutablePointer(to: &cif) { (pcif) -> Void in
            withUnsafeMutableBytes(of: &returnValue, { (pReturnValue) -> Void in
                ffi_call(pcif,
                         unsafeBitCast(imp, to: (@convention(c) () -> Void).self),
                         pReturnValue.baseAddress,
                         arguments.baseAddress)
            })
        }
        XCTAssertEqual(returnValue, arg1 + arg2)
    }
    
    func testLibffiClosure() {
        var cif: ffi_cif = ffi_cif()
        let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
        defer { argumentTypes.deallocate() }
        argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[2] = UnsafeMutablePointer(&ffi_type_sint64)
        argumentTypes[3] = UnsafeMutablePointer(&ffi_type_sint64)
        let status_cif = withUnsafeMutablePointer(to: &cif) { (p) -> ffi_status in
            ffi_prep_cif(
                p,
                FFI_DEFAULT_ABI,
                4,
                UnsafeMutablePointer(&ffi_type_sint64),
                argumentTypes.baseAddress)
        }
        XCTAssertEqual(status_cif, FFI_OK)
        
        var newIMP: IMP!
        let closure: UnsafeMutablePointer<ffi_closure>? = withUnsafeMutablePointer(to: &newIMP) { (p) -> UnsafeMutablePointer<ffi_closure>? in
            p.withMemoryRebound(to: UnsafeMutableRawPointer?.self, capacity: 1) {
                return  UnsafeMutablePointer<ffi_closure>(OpaquePointer(ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, $0)))
            }
        }
        
        defer { ffi_closure_free(closure) }
        XCTAssertNotNil(closure)
        XCTAssertNotNil(newIMP)
        
        func closureCalled(cif: UnsafeMutablePointer<ffi_cif>?,
                           ret: UnsafeMutableRawPointer?,
                           args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                           userdata: UnsafeMutableRawPointer?) {
            let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: 4)
            let arg1 = (UnsafePointer<Int>(OpaquePointer(argsBuffer[2]))?.pointee)!
            let arg2 = (UnsafePointer<Int>(OpaquePointer(argsBuffer[3]))?.pointee)!
            ret?.bindMemory(to: Int.self, capacity: 1).pointee = arg1 * arg2
        }
        
        var userData: Any?
        let status_closure = withUnsafeMutablePointer(to: &cif) { (pcif) -> ffi_status in
            withUnsafeMutableBytes(of: &userData) { (pUserData) -> ffi_status in
                ffi_prep_closure_loc(
                    closure,
                    pcif,
                    closureCalled,
                    pUserData.baseAddress,
                    unsafeBitCast(newIMP, to: UnsafeMutableRawPointer.self))
            }
        }
        XCTAssertEqual(status_closure, FFI_OK)
        
        let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.sumFunc(a:b:)))
        let originalMethod = method_setImplementation(method!, newIMP!)
        defer {
            method_setImplementation(method!, originalMethod)
        }
        
        let object = TestObject()
        let maxTestInt = Int(sqrt(Double(Int.max)))
        let arg1 = Int.random(in: -maxTestInt ... maxTestInt)
        let arg2 = Int.random(in: -maxTestInt ... maxTestInt)
        let result = object.sumFunc(a: arg1, b: arg2)
        XCTAssertEqual(result, arg1 * arg2)
    }
    
    func test_Libffi_Call_Struct() {
        var elementsTypes = [UnsafeMutablePointer<ffi_type>?]()
        elementsTypes.append(&ffi_type_double)
        elementsTypes.append(&ffi_type_double)
        elementsTypes.append(nil)
        
        var pointType = ffi_type.init()
        pointType.size = 0
        pointType.alignment = 0
        pointType.type = UInt16(FFI_TYPE_STRUCT)
        elementsTypes.withUnsafeMutableBufferPointer { (pointer) -> Void in
            pointType.elements = pointer.baseAddress
        }
        
        var cif = ffi_cif()
        var argumentTypes = [UnsafeMutablePointer<ffi_type>?]()
        argumentTypes.append(&ffi_type_pointer)
        argumentTypes.append(&ffi_type_pointer)
        argumentTypes.append(&pointType)
        
        let status_cif = argumentTypes.withUnsafeMutableBufferPointer { (pointer) -> ffi_status in
            withUnsafeMutablePointer(to: &cif) { (p) -> ffi_status in
                ffi_prep_cif(
                    p,
                    FFI_DEFAULT_ABI,
                    3,
                    UnsafeMutablePointer(&ffi_type_sint64),
                    pointer.baseAddress
                )
            }
        }
        XCTAssertEqual(status_cif, FFI_OK)
        
        var obj = TestObject.init()
        var selector = #selector(TestObject.testPoint(point:))
        let imp = class_getMethodImplementation(TestObject.self, selector)
        var arg1 = CGPoint.init(x: 11, y: 22)
        
        var arguments = [UnsafeMutableRawPointer?]()
        arguments.append(&obj)
        arguments.append(&selector)
        arguments.append(&arg1)
        
        arguments.withUnsafeMutableBufferPointer { (argumentsPointer) -> Void in
            withUnsafeMutablePointer(to: &cif) { (pcif) -> Void in
                ffi_call(pcif,
                         unsafeBitCast(imp, to: (@convention(c) () -> Void).self),
                         nil,
                         argumentsPointer.baseAddress)
            }
        }
        
    }
    
    func test_Libffi_Closure_Struct() {
        var elementsTypes = [UnsafeMutablePointer<ffi_type>?]()
        elementsTypes.append(&ffi_type_double)
        elementsTypes.append(&ffi_type_double)
        elementsTypes.append(nil)
        
        var pointType = ffi_type.init()
        pointType.size = 0
        pointType.alignment = 0
        pointType.type = UInt16(FFI_TYPE_STRUCT)
        elementsTypes.withUnsafeMutableBufferPointer { (pointer) -> Void in
            pointType.elements = pointer.baseAddress
        }
        
        var cif = ffi_cif()
        var argumentTypes = [UnsafeMutablePointer<ffi_type>?]()
        argumentTypes.append(&ffi_type_pointer)
        argumentTypes.append(&ffi_type_pointer)
        argumentTypes.append(&pointType)
        
        let status_cif = argumentTypes.withUnsafeMutableBufferPointer { (pointer) -> ffi_status in
            withUnsafeMutablePointer(to: &cif) { (p) -> ffi_status in
                ffi_prep_cif(
                    p,
                    FFI_DEFAULT_ABI,
                    3,
                    UnsafeMutablePointer(&ffi_type_sint64),
                    pointer.baseAddress
                )
            }
        }
        XCTAssertEqual(status_cif, FFI_OK)
        
        var newIMP: UnsafeMutableRawPointer?
        let closure = withUnsafeMutablePointer(to: &newIMP) { (newIMPPointer) -> UnsafeMutablePointer<ffi_closure>? in
            return ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, newIMPPointer)?.assumingMemoryBound(to: ffi_closure.self)
        }
        
        defer { ffi_closure_free(closure) }
        XCTAssertNotNil(closure)
        XCTAssertNotNil(newIMP)
        
        func closureCalled(cif: UnsafeMutablePointer<ffi_cif>?,
                           ret: UnsafeMutableRawPointer?,
                           args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                           userdata: UnsafeMutableRawPointer?) {
            let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: 3)
            assert(argsBuffer[2]?.assumingMemoryBound(to: CGPoint.self).pointee == CGPoint.init(x: 11, y: 22))
        }
        
        let status_closure = withUnsafeMutablePointer(to: &cif) { (pcif) -> ffi_status in
            ffi_prep_closure_loc(
                closure,
                pcif,
                closureCalled,
                nil,
                unsafeBitCast(newIMP, to: UnsafeMutableRawPointer.self))
        }
        XCTAssertEqual(status_closure, FFI_OK)
        
        let method = class_getInstanceMethod(TestObject.self, #selector(TestObject.testPoint(point:)))
        let originalMethod = method_setImplementation(method!, unsafeBitCast(newIMP!, to: IMP.self))
        defer {
            method_setImplementation(method!, originalMethod)
        }
        
        let object = TestObject()
        let arg1 = CGPoint.init(x: 11, y: 22)
        object.testPoint(point: arg1)
    }
}
