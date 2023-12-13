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
        withUnsafeMutablePointer(to: &cif) { cifPointer in
            let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
            defer { argumentTypes.deallocate() }
            argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
            argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
            argumentTypes[2] = UnsafeMutablePointer(&ffi_type_sint64)
            argumentTypes[3] = UnsafeMutablePointer(&ffi_type_sint64)
            let status_cif = ffi_prep_cif(
                cifPointer,
                FFI_DEFAULT_ABI,
                4,
                UnsafeMutablePointer(&ffi_type_sint64),
                argumentTypes.baseAddress)
            XCTAssertEqual(status_cif, FFI_OK)
            
            var obj = TestObject.init()
            var selector = #selector(TestObject.sumFunc(a:b:))
            let imp = class_getMethodImplementation(TestObject.self, selector)
            var arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
            var arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
            var returnValue: Int = 0
            
            withUnsafeMutablePointer(to: &obj) { objPointer in
                withUnsafeMutablePointer(to: &selector) { selectorPointer in
                    withUnsafeMutablePointer(to: &arg1) { arg1Pointer in
                        withUnsafeMutablePointer(to: &arg2) { arg2Pointer in
                            withUnsafeMutableBytes(of: &returnValue, { pReturnValue in
                                let arguments = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>.allocate(capacity: 4)
                                defer { arguments.deallocate() }
                                arguments[0] = UnsafeMutableRawPointer(objPointer)
                                arguments[1] = UnsafeMutableRawPointer(selectorPointer)
                                arguments[2] = UnsafeMutableRawPointer(arg1Pointer)
                                arguments[3] = UnsafeMutableRawPointer(arg2Pointer)
                                ffi_call(cifPointer,
                                         unsafeBitCast(imp, to: (@convention(c) () -> Void).self),
                                         pReturnValue.baseAddress,
                                         arguments.baseAddress)
                            })
                        }
                    }
                }
            }
            XCTAssertEqual(returnValue, arg1 + arg2)
        }
    }
    
    func testLibffiClosure() {
        var cif: ffi_cif = ffi_cif()
        withUnsafeMutablePointer(to: &cif) { cifPointer in
            let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 4)
            defer { argumentTypes.deallocate() }
            argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
            argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
            argumentTypes[2] = UnsafeMutablePointer(&ffi_type_sint64)
            argumentTypes[3] = UnsafeMutablePointer(&ffi_type_sint64)
            
            let status_cif = ffi_prep_cif(
                cifPointer,
                FFI_DEFAULT_ABI,
                4,
                UnsafeMutablePointer(&ffi_type_sint64),
                argumentTypes.baseAddress)
            XCTAssertEqual(status_cif, FFI_OK)
            
            var newIMP: IMP!
            let closure: UnsafeMutablePointer<ffi_closure>? = withUnsafeMutablePointer(to: &newIMP) { (newIMPPointer) -> UnsafeMutablePointer<ffi_closure>? in
                let pointer = unsafeBitCast(newIMPPointer, to: UnsafeMutablePointer<UnsafeMutableRawPointer?>?.self)
                let closurePointer = ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, pointer)
                return closurePointer?.assumingMemoryBound(to: ffi_closure.self)
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
            let status_closure = withUnsafeMutableBytes(of: &userData) { (pUserData) -> ffi_status in
                ffi_prep_closure_loc(
                    closure,
                    cifPointer,
                    closureCalled,
                    pUserData.baseAddress,
                    unsafeBitCast(newIMP, to: UnsafeMutableRawPointer.self))
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
    
    func test_Libffi_Call_Struct() {
        let elementsTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 3)
        defer { elementsTypes.deallocate() }
        elementsTypes[0] = UnsafeMutablePointer(&ffi_type_double)
        elementsTypes[1] = UnsafeMutablePointer(&ffi_type_double)
        elementsTypes[2] = nil
        
        var pointType = ffi_type.init()
        pointType.size = 0
        pointType.alignment = 0
        pointType.type = UInt16(FFI_TYPE_STRUCT)
        pointType.elements = elementsTypes.baseAddress
        
        withUnsafeMutablePointer(to: &pointType) { pointTypePointer in
            var cif = ffi_cif()
            withUnsafeMutablePointer(to: &cif) { cifPointer in
                let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 3)
                defer { argumentTypes.deallocate() }
                argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
                argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
                argumentTypes[2] = UnsafeMutablePointer(pointTypePointer)
                let status_cif = ffi_prep_cif(
                    cifPointer,
                    FFI_DEFAULT_ABI,
                    3,
                    UnsafeMutablePointer(&ffi_type_sint64),
                    argumentTypes.baseAddress
                )
                XCTAssertEqual(status_cif, FFI_OK)
                var obj = TestObject.init()
                var selector = #selector(TestObject.testPoint(point:))
                let imp = class_getMethodImplementation(TestObject.self, selector)
                var arg1 = CGPoint.init(x: 11, y: 22)
                withUnsafeMutablePointer(to: &obj) { objPointer in
                    withUnsafeMutablePointer(to: &selector) { selectorPointer in
                        withUnsafeMutablePointer(to: &arg1) { arg1Pointer in
                            let arguments = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>.allocate(capacity: 3)
                            defer { arguments.deallocate() }
                            arguments[0] = UnsafeMutableRawPointer(objPointer)
                            arguments[1] = UnsafeMutableRawPointer(selectorPointer)
                            arguments[2] = UnsafeMutableRawPointer(arg1Pointer)
                            ffi_call(cifPointer,
                                     unsafeBitCast(imp, to: (@convention(c) () -> Void).self),
                                     nil,
                                     arguments.baseAddress)
                        }
                    }
                }
            }
        }
    }
    
    func test_Libffi_Closure_Struct() {
        let elementsTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 3)
        defer { elementsTypes.deallocate() }
        elementsTypes[0] = UnsafeMutablePointer(&ffi_type_double)
        elementsTypes[1] = UnsafeMutablePointer(&ffi_type_double)
        elementsTypes[2] = nil
        
        var pointType = ffi_type.init()
        pointType.size = 0
        pointType.alignment = 0
        pointType.type = UInt16(FFI_TYPE_STRUCT)
        pointType.elements = elementsTypes.baseAddress
        
        withUnsafeMutablePointer(to: &pointType) { pointTypePointer in
            var cif = ffi_cif()
            withUnsafeMutablePointer(to: &cif) { cifPointer in
                let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 3)
                defer { argumentTypes.deallocate() }
                argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
                argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
                argumentTypes[2] = UnsafeMutablePointer(pointTypePointer)
                let status_cif = ffi_prep_cif(
                    cifPointer,
                    FFI_DEFAULT_ABI,
                    3,
                    UnsafeMutablePointer(&ffi_type_sint64),
                    argumentTypes.baseAddress
                )
                
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
                
                let status_closure = ffi_prep_closure_loc(
                    closure,
                    cifPointer,
                    closureCalled,
                    nil,
                    unsafeBitCast(newIMP, to: UnsafeMutableRawPointer.self))
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
    }
}
