//
//  InstanceBeforeTests.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 14/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import XCTest
import iOSHook
import libffi

class InstanceBeforeTests: XCTestCase {
    
    func testHook() {
        withMemoryTest {
            try! TestObject.hook(selector: #selector(TestObject.noArgsNoReturnFunc),
                                 signature: (nil, nil),
                                 block: { (original, args: Void) -> Void in
                                    return original(args)
            })
        }
    }
    
    func testLibffiCall() {
        withMemoryTest {
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
    }
    
    func testLibffiClosure() {
        withMemoryTest {
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
            
            // TODO:
            let newIMP: IMP? = nil
            var newIMPPointer = UnsafeMutableRawPointer(newIMP)
            let closure = ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, UnsafeMutablePointer(&newIMPPointer))
            defer { ffi_closure_free(closure) }
            _ = 1
        }
    }
    
    // MARK: utilities
    
    func getMemory() -> UInt64 {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return taskInfo.resident_size
        }
        else {
            XCTAssert(false)
            assert(false)
        }
    }
    
    func withMemoryTest(closure: ()->()) {
        let before = getMemory()
        for _ in 0...1000000 {
            closure()
        }
        let after = getMemory()
        let diff = Double(after - before)/1024/1024
        print("Memory cast \(diff) M")
        XCTAssertLessThan(diff, 0.5)
    }
}
