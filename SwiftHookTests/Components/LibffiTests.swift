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
        var argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
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
        var argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
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
        
        var newIMP: IMP?
        var closure: UnsafeMutablePointer<ffi_closure>? = withUnsafeMutablePointer(to: &newIMP) { (p) -> UnsafeMutablePointer<ffi_closure>? in
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
                withUnsafeMutableBytes(of: &newIMP) { (pNewIMP) -> ffi_status in
                    ffi_prep_closure_loc(
                        closure,
                        pcif,
                        closureCalled,
                        pUserData.baseAddress,
                        pNewIMP.baseAddress)
                }
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
}
