//
//  HookToken.swift
//  SwiftHook
//
//  Created by Yanni Wang on 27/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import libffi

public class HookToken {
    enum Mode {
        case before
        case after
        case instead
    }
    
    let `class`: AnyClass
    let selector : Selector
    let mode: Mode
    let hookBlock: AnyObject
    
    let originalIMP: IMP
    let newIMP: IMP
    let argumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    let cif: ffi_cif
    let closure: UnsafeMutableRawPointer
    
    private init(class: AnyClass, selector: Selector, mode: Mode, hookBlock: AnyObject) throws {
        self.`class` = `class`
        self.selector = selector
        self.mode = mode
        self.hookBlock = hookBlock
        
        // IMP
        self.originalIMP = try {
            var length: UInt32 = 0
            let firstMethod = class_copyMethodList(`class`, UnsafeMutablePointer(&length))
            let bufferPointer = UnsafeBufferPointer.init(start: firstMethod, count: Int(length))
            for method in bufferPointer {
                if method_getName(method) == selector {
                    return method_getImplementation(method)
                }
            }
            throw SwiftHookError.unknow
            }()
        
        // argumentTypes
        self.argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 2)
        self.argumentTypes[0] = UnsafeMutablePointer(&ffi_type_pointer)
        self.argumentTypes[1] = UnsafeMutablePointer(&ffi_type_pointer)
        
        // cif
        var cif: ffi_cif = ffi_cif()
        let status_cif = ffi_prep_cif(
            UnsafeMutablePointer(&cif),
            FFI_DEFAULT_ABI,
            2,
            UnsafeMutablePointer(&ffi_type_pointer),
            argumentTypes.baseAddress)
        guard status_cif == FFI_OK else {
            throw SwiftHookError.ffiError
        }
        self.cif = cif
        
        // closure & newIMP
        var newIMP: IMP? = nil
        var closure: UnsafeMutableRawPointer? = nil
        UnsafeMutablePointer(&newIMP).withMemoryRebound(to: UnsafeMutableRawPointer?.self, capacity: 1) {
            closure = ffi_closure_alloc(MemoryLayout<ffi_closure>.stride,$0)
        }
        guard let closureNoNil = closure, let newIMPNoNil = newIMP else {
            throw SwiftHookError.ffiError
        }
        self.closure = closureNoNil
        self.newIMP = newIMPNoNil
        
        // TODO:
//        let status_closure = ffi_prep_closure_loc(
//            UnsafeMutablePointer<ffi_closure>(OpaquePointer(closure)),
//            UnsafeMutablePointer(&cif),
//            HookToken.closureCalled,
//            UnsafeMutableRawPointer(&self),
//            UnsafeMutableRawPointer(&newIMP))
//        XCTAssertEqual(status_closure, FFI_OK)
    }
    
    deinit {
        argumentTypes.deallocate()
        ffi_closure_free(closure)
    }
    
    static func closureCalled(cif: UnsafeMutablePointer<ffi_cif>?,
                              ret: UnsafeMutableRawPointer?,
                              args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                              userdata: UnsafeMutableRawPointer?) {
        let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: 4)
        let arg1 = (UnsafePointer<Int>(OpaquePointer(argsBuffer[2]))?.pointee)!
        let arg2 = (UnsafePointer<Int>(OpaquePointer(argsBuffer[3]))?.pointee)!
        ret?.bindMemory(to: Int.self, capacity: 1).pointee = arg1 * arg2
    }
    
    class func hook(class: AnyClass, selector: Selector, mode: Mode, hookBlock: AnyObject) throws -> HookToken{
        let hookToken = try HookToken.init(class: `class`, selector: selector, mode: mode, hookBlock: hookBlock)
        return hookToken
    }
}
