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
            let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
            defer { argumentTypes.deallocate() }
            argumentTypes[0] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            argumentTypes[1] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            argumentTypes[2] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            argumentTypes[3] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            let status = ffi_prep_cif(withUnsafeMutablePointer(to: &cif) {$0},
                                      FFI_DEFAULT_ABI,
                                      4,
                                      withUnsafeMutablePointer(to: &ffi_type_pointer) {$0},
                                      argumentTypes.baseAddress)
            XCTAssertEqual(status, FFI_OK)
            
            
            var obj = TestObject.init()
            var selector = #selector(TestObject.sumFunc(a:b:))
            var arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
            var arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
            let imp = obj.method(for: selector)
            var returnValue: Int = 0
            let arguments = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>.allocate(capacity: 4)
            defer { arguments.deallocate() }
            arguments[0] = withUnsafeMutablePointer(to: &obj, {UnsafeMutableRawPointer($0)})
            arguments[1] = withUnsafeMutablePointer(to: &selector, {UnsafeMutableRawPointer($0)})
            arguments[2] = withUnsafeMutablePointer(to: &arg1, {UnsafeMutableRawPointer($0)})
            arguments[3] = withUnsafeMutablePointer(to: &arg2, {UnsafeMutableRawPointer($0)})
            
            ffi_call(withUnsafeMutablePointer(to: &cif) {$0},
                     unsafeBitCast(imp, to: (@convention(c) () -> Void)?.self),
                     withUnsafeMutablePointer(to: &returnValue){$0},
                     arguments.baseAddress)
            
            XCTAssertEqual(returnValue, arg1 + arg2)
        }
    }
    
    func testLibffiClosure() {
        withMemoryTest {
            var cif: ffi_cif = ffi_cif()
            let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
            defer { argumentTypes.deallocate() }
            argumentTypes[0] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            argumentTypes[1] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            argumentTypes[2] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            argumentTypes[3] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
            let status = ffi_prep_cif(withUnsafeMutablePointer(to: &cif) {$0},
                                      FFI_DEFAULT_ABI,
                                      4,
                                      withUnsafeMutablePointer(to: &ffi_type_pointer) {$0},
                                      argumentTypes.baseAddress)
            XCTAssertEqual(status, FFI_OK)
            
            let newIMP: IMP? = nil
            var newIMPPointer = UnsafeMutableRawPointer.init(newIMP)
            let closure = ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, withUnsafeMutablePointer(to: &newIMPPointer, {$0}))
            defer { ffi_closure_free(closure) }
            // TODO:
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
