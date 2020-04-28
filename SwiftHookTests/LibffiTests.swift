//
//  LibffiTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 26/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
import libffi

class LibffiTests: XCTestCase {
    
    func testLibffiCall() {
        var cif: ffi_cif = ffi_cif()
        var argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
        defer { argumentTypes.deallocate() }
        argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[2] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[3] = UnsafeMutablePointer(&ffi_type_pointer)
        let status_cif = ffi_prep_cif(
            UnsafeMutablePointer(&cif),
            FFI_DEFAULT_ABI,
            4,
            UnsafeMutablePointer(&ffi_type_pointer),
            argumentTypes.baseAddress)
        XCTAssertEqual(status_cif, FFI_OK)
        
        var obj = TestObject.init()
        var selector = #selector(TestObject.sumFunc(a:b:))
        let imp = obj.method(for: selector)
        var arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
        var arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
        var returnValue: Int = 0
        let arguments = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>.allocate(capacity: 4)
        defer { arguments.deallocate() }
        arguments[0] = UnsafeMutableRawPointer(&obj)
        arguments[1] = UnsafeMutableRawPointer(&selector)
        arguments[2] = UnsafeMutableRawPointer(&arg1)
        arguments[3] = UnsafeMutableRawPointer(&arg2)
        
        ffi_call(UnsafeMutablePointer(&cif),
                 unsafeBitCast(imp, to: (@convention(c) () -> Void)?.self),
                 UnsafeMutableRawPointer(&returnValue),
                 arguments.baseAddress)
        
        XCTAssertEqual(returnValue, arg1 + arg2)
    }
    
    func testLibffiClosure() {
        var cif: ffi_cif = ffi_cif()
        var argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
        defer { argumentTypes.deallocate() }
        argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[2] = UnsafeMutablePointer(&ffi_type_pointer)
        argumentTypes[3] = UnsafeMutablePointer(&ffi_type_pointer)
        let status_cif = ffi_prep_cif(
            UnsafeMutablePointer(&cif),
            FFI_DEFAULT_ABI,
            4,
            UnsafeMutablePointer(&ffi_type_pointer),
            argumentTypes.baseAddress)
        XCTAssertEqual(status_cif, FFI_OK)
        
        var newIMP: IMP? = nil
        var closure: UnsafeMutablePointer<ffi_closure>? = nil;
        UnsafeMutablePointer(&newIMP).withMemoryRebound(to: UnsafeMutableRawPointer?.self, capacity: 1) {
            closure = UnsafeMutablePointer<ffi_closure>(OpaquePointer(ffi_closure_alloc(MemoryLayout<ffi_closure>.stride,$0)))
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
        
        var userData: Any? = nil
        let status_closure = ffi_prep_closure_loc(
            closure,
            UnsafeMutablePointer(&cif),
            closureCalled,
            UnsafeMutableRawPointer(&userData),
            UnsafeMutableRawPointer(&newIMP))
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
    
    func testMemory() {
//        while true {
//            testLibffiCall()
//            testLibffiClosure()
//        }
    }
    
//    func testMemory() {
//        testLibffiCall()
//        testLibffiClosure()
//        let before = getMemory()
//        for _ in 0...10000 {
//            testLibffiCall()
//            testLibffiClosure()
//        }
//        let after = getMemory()
//        let diff = Double(after - before)/1024/1024
//        print("Memory cast \(diff) M")
//        XCTAssertLessThan(diff, 0.3)
//    }
//
//    // MARK: utilities
//
//    func getMemory() -> UInt64 {
//        var taskInfo = mach_task_basic_info()
//        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
//        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
//            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
//            }
//        }
//
//        if kerr == KERN_SUCCESS {
//            return taskInfo.resident_size
//        }
//        else {
//            XCTAssert(false)
//            assert(false)
//        }
//    }
    
}
