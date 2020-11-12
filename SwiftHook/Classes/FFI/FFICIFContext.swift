//
//  FFICIFContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 2/6/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

class FFICIFContext {
    private let argTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    private let returnType: UnsafeMutablePointer<ffi_type>
    private var typeContexts = Set<FFITypeContext>()
    let cif: UnsafeMutablePointer<ffi_cif>
    
    init(signature: Signature) throws {
        self.argTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: signature.argumentTypes.count)
        var deallocateHelperArgTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>? = self.argTypes
        defer {
            deallocateHelperArgTypes?.deallocate()
        }
        for (index, argumentType) in signature.argumentTypes.enumerated() {
            guard let typeContext = FFITypeContext(typeEncoding: argumentType.code) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            self.typeContexts.insert(typeContext)
            self.argTypes[index] = typeContext.ffiType
        }
        guard let returnType = FFITypeContext(typeEncoding: signature.returnType.code) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.typeContexts.insert(returnType)
        self.returnType = returnType.ffiType
        self.cif = UnsafeMutablePointer.allocate(capacity: 1)
        var deallocateHelperHookCif: UnsafeMutablePointer? = self.cif
        defer {
            deallocateHelperHookCif?.deallocate()
        }
        guard (ffi_prep_cif(
            self.cif,
            FFI_DEFAULT_ABI,
            UInt32(signature.argumentTypes.count),
            self.returnType,
            self.argTypes.baseAddress)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        
        deallocateHelperArgTypes = nil
        deallocateHelperHookCif = nil
    }
    
    deinit {
        self.cif.deallocate()
        self.argTypes.deallocate()
    }
}
