//
//  FFIClosureContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 2/6/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import libffi_apple

class FFIClosureContext {
    private let ffiClosure: UnsafeMutablePointer<ffi_closure>
    let targetIMP: IMP
    
    init(cif: UnsafeMutablePointer<ffi_cif>, userData: UnsafeMutableRawPointer, fun: @escaping @convention(c) (UnsafeMutablePointer<ffi_cif>?, UnsafeMutableRawPointer?, UnsafeMutablePointer<UnsafeMutableRawPointer?>?, UnsafeMutableRawPointer?) -> Void) throws {
        var targetIMP: UnsafeMutableRawPointer?
        self.ffiClosure = try withUnsafeMutablePointer(to: &targetIMP) { (pointer) -> UnsafeMutablePointer<ffi_closure> in
            guard let closure = ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, pointer) else {
                throw SwiftHookError.ffiError
            }
            return closure.assumingMemoryBound(to: ffi_closure.self)
        }
        var deallocateHelperFfiClosure: UnsafeMutablePointer<ffi_closure>? = self.ffiClosure
        defer {
            if let deallocateHelperFfiClosure = deallocateHelperFfiClosure {
                ffi_closure_free(deallocateHelperFfiClosure)
            }
        }
        self.targetIMP = unsafeBitCast(targetIMP!, to: IMP.self)
        guard ffi_prep_closure_loc(self.ffiClosure, cif, fun, userData, targetIMP) == FFI_OK else {
            throw SwiftHookError.ffiError
        }
        deallocateHelperFfiClosure = nil
    }
    
    deinit {
        ffi_closure_free(self.ffiClosure)
    }
}
