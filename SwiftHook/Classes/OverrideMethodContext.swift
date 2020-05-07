//
//  OverrideMethodContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 5/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private func closureCalled(cif: UnsafeMutablePointer<ffi_cif>?,
                           ret: UnsafeMutableRawPointer?,
                           args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                           userdata: UnsafeMutableRawPointer?) {
    guard let userdata = userdata else {
        assert(false)
        return
    }
    let overrideMethodContext = Unmanaged<OverrideMethodContext>.fromOpaque(userdata).takeUnretainedValue()
    guard let sueprClass = class_getSuperclass(overrideMethodContext.targetClass) else {
        assert(false)
        return
    }
    guard let method = class_getMethodImplementation(sueprClass, overrideMethodContext.selector) else {
        assert(false)
        return
    }
    ffi_call(overrideMethodContext.cifPointer, unsafeBitCast(method, to: (@convention(c) () -> Void).self), ret, args)
}

// TODO: use manager
private var allOverrideMethodContext = [OverrideMethodContext]()

class OverrideMethodContext {
    
    fileprivate let targetClass: AnyClass
    fileprivate let selector: Selector
    private let superMethod: Method
    
    private let methodSignature: Signature
    
    private let newIMP: IMP
    private let argumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    fileprivate let cifPointer: UnsafeMutablePointer<ffi_cif>
    private let closure: UnsafeMutablePointer<ffi_closure>
    
    private let typeContexts: [SHFFITypeContext]
    
    private init(targetClass: AnyClass, selector: Selector) throws {
        self.targetClass = targetClass
        self.selector = selector
        
        // Check self Method
        guard getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        
        // superMethod
        guard let superMethod = class_getInstanceMethod(self.targetClass, self.selector) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.superMethod = superMethod
        
        // Signature
        guard let methodSignature = Signature(method: self.superMethod) else {
            throw SwiftHookError.missingSignature
        }
        self.methodSignature = methodSignature
        
        // argumentTypes,
        self.argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: methodSignature.argumentTypes.count)
        var typeContexts = [SHFFITypeContext]()
        for (index, argumentType) in methodSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            typeContexts.append(typeContext)
            self.argumentTypes[index] = typeContext.ffiType
        }
        
        // returnTypes
        guard let returnTypeContext = SHFFITypeContext(typeEncoding: methodSignature.returnType) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        typeContexts.append(returnTypeContext)
        let returnFFIType = returnTypeContext.ffiType
        
        // typeContexts
        self.typeContexts = typeContexts
        
        // cif
        self.cifPointer = UnsafeMutablePointer.allocate(capacity: 1)
        let status_cif = ffi_prep_cif(
            self.cifPointer,
            FFI_DEFAULT_ABI,
            UInt32(methodSignature.argumentTypes.count),
            returnFFIType,
            self.argumentTypes.baseAddress)
        guard status_cif == FFI_OK else {
            throw SwiftHookError.ffiError
        }
        
        // closure & newIMP
        var newIMP: IMP?
        var closure: UnsafeMutablePointer<ffi_closure>?
        UnsafeMutablePointer(&newIMP).withMemoryRebound(to: UnsafeMutableRawPointer?.self, capacity: 1) {
            closure = UnsafeMutablePointer<ffi_closure>(OpaquePointer(ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, $0)))
        }
        guard let closureNoNil = closure, let newIMPNoNil = newIMP else {
            throw SwiftHookError.ffiError
        }
        self.closure = closureNoNil
        self.newIMP = newIMPNoNil
        
        let status_closure = ffi_prep_closure_loc(
            self.closure,
            self.cifPointer,
            closureCalled,
            Unmanaged.passUnretained(self).toOpaque(),
            UnsafeMutableRawPointer(&newIMP))
        guard status_closure == FFI_OK else {
            throw SwiftHookError.ffiError
        }
        
        // add Method
        guard class_addMethod(self.targetClass, self.selector, self.newIMP, method_getTypeEncoding(self.superMethod)) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
    }
    
    deinit {
        self.argumentTypes.deallocate()
        self.cifPointer.deallocate()
        ffi_closure_free(self.closure)
    }
    
    class func overrideSuperMethod(targetClass: AnyClass, selector: Selector) throws {
        let overrideMethodContext = try OverrideMethodContext.init(targetClass: targetClass, selector: selector)
        allOverrideMethodContext.append(overrideMethodContext)
    }
    
    // MARK: This is debug tools.
    
    class func debugToolsGetAllOverrideMethodContext() -> [OverrideMethodContext] {
        return allOverrideMethodContext
    }
}
