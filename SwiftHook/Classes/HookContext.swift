//
//  HookContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 27/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import libffi_iOS

private func closureCalled(cif: UnsafeMutablePointer<ffi_cif>?,
                           ret: UnsafeMutableRawPointer?,
                           args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                           userdata: UnsafeMutableRawPointer?) {
    guard let userdata = userdata else {
        assert(false)
        return
    }
    let hookContext = Unmanaged<HookContext>.fromOpaque(userdata).takeUnretainedValue()
    switch hookContext.mode {
    case .before:
        ffi_call(hookContext.cifPointer, unsafeBitCast(hookContext.hookBlockIMP, to: (@convention(c) () -> Void).self), ret, args)
        ffi_call(hookContext.cifPointer, unsafeBitCast(hookContext.originalIMP, to: (@convention(c) () -> Void).self), ret, args)
    case .after:
        break
    case .instead:
        break
    }
}

private var allHookContext = [HookContext]()

public class HookContext {
    
    private let `class`: AnyClass
    private let selector: Selector
    fileprivate let mode: HookMode
    private let hookBlock: AnyObject
    private let method: Method
    
    private let methodSignature: Signature
    private let closureSignature: Signature
    
    fileprivate let hookBlockIMP: IMP
    fileprivate let originalIMP: IMP
    private let newIMP: IMP
    private let argumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    fileprivate let cifPointer: UnsafeMutablePointer<ffi_cif>
    private let closure: UnsafeMutablePointer<ffi_closure>
    
    private let typeContexts: [SHFFITypeContext]
    
    private init(class: AnyClass, selector: Selector, mode: HookMode, hookBlock: AnyObject) throws {
        self.`class` = `class`
        self.selector = selector
        self.mode = mode
        self.hookBlock = hookBlock
        
        // hookBlockIMP
        self.hookBlockIMP = imp_implementationWithBlock(self.hookBlock)
        
        // Method
        self.method = try {
            var length: UInt32 = 0
            let firstMethod = class_copyMethodList(`class`, UnsafeMutablePointer(&length))
            let bufferPointer = UnsafeBufferPointer.init(start: firstMethod, count: Int(length))
            for method in bufferPointer {
                if method_getName(method) == selector {
                    return method
                }
            }
            throw SwiftHookError.unknow
            }()
        
        // Signature
        guard let methodSignature = Signature(method: self.method),
            let closureSignature = Signature(closure: hookBlock) else {
                throw SwiftHookError.missingSignature
        }
        self.methodSignature = methodSignature
        self.closureSignature = closureSignature
        
        // IMP
        self.originalIMP = method_getImplementation(self.method)
        
        // argumentTypes,
        self.argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: methodSignature.argumentTypes.count)
        var typeContexts = [SHFFITypeContext]()
        for (index, argumentType) in methodSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.unknow
            }
            typeContexts.append(typeContext)
            self.argumentTypes[index] = typeContext.ffiType
        }
        
        // returnTypes
        guard let returnTypeContext = SHFFITypeContext(typeEncoding: methodSignature.returnType) else {
            throw SwiftHookError.unknow
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
        
        // swizzling
        method_setImplementation(self.method, self.newIMP)
    }
    
    deinit {
        self.argumentTypes.deallocate()
        self.cifPointer.deallocate()
        ffi_closure_free(self.closure)
        imp_removeBlock(self.hookBlockIMP)
    }
    
    class func hook(class: AnyClass, selector: Selector, mode: HookMode, hookBlock: AnyObject) throws -> HookContext {
        let hookContext = try HookContext.init(class: `class`, selector: selector, mode: mode, hookBlock: hookBlock)
        allHookContext.append(hookContext)
        return hookContext
    }
    
    /**
     # Cancel hook.
     Try to change the Method's IMP from hooked to original and released context.
     But it's dangerous when the current IMP is not previous hooked IMP. In this case. cancelHook() still works fine but the context will not be released.
     
     - returns:
     If context will be released, return true. otherwise return false.
     */
    @discardableResult
    public func cancelHook() -> Bool {
        // TODO: 
        return false
    }
}
