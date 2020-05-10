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
    let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: hookContext.methodSignature.argumentTypes.count)
    
    let argsFilteredBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>.allocate(capacity: hookContext.closureSignature.argumentTypes.count)
    defer {
        argsFilteredBuffer.deallocate()
    }
    var hookClosure = hookContext.hookClosure
    var originalClosureForInstead: Any?
    if hookContext.mode == .instead {
        originalClosureForInstead = createOriginalClosureForInstead(
            argsBuffer[0]!.assumingMemoryBound(to: AnyObject.self).pointee,
            argsBuffer[1]!.assumingMemoryBound(to: Selector.self).pointee,
            hookContext.originalIMP, hookContext.originalCIFPointer)
    }
    for index in 0 ... hookContext.closureSignature.argumentTypes.count - 1 {
        if index == 0 {
            argsFilteredBuffer[index] = UnsafeMutableRawPointer(&hookClosure)
        } else {
            if hookContext.mode == .instead {
                if index == 1 {
                    argsFilteredBuffer[index] = UnsafeMutableRawPointer(&originalClosureForInstead)
                } else {
                    argsFilteredBuffer[index] = argsBuffer[index]
                }
            } else {
                argsFilteredBuffer[index] = argsBuffer[index + 1]
            }
        }
    }
    
    switch hookContext.mode {
    case .before:
        ffi_call(hookContext.hookCIFPointer, hookContext.hookClosureInvoke, ret, argsFilteredBuffer.baseAddress)
        ffi_call(hookContext.originalCIFPointer, unsafeBitCast(hookContext.originalIMP, to: (@convention(c) () -> Void).self), ret, args)
    case .after:
        ffi_call(hookContext.originalCIFPointer, unsafeBitCast(hookContext.originalIMP, to: (@convention(c) () -> Void).self), ret, args)
        ffi_call(hookContext.hookCIFPointer, hookContext.hookClosureInvoke, ret, argsFilteredBuffer.baseAddress)
    case .instead:
        ffi_call(hookContext.hookCIFPointer, hookContext.hookClosureInvoke, ret, argsFilteredBuffer.baseAddress)
    }
}

public class HookContext {
    
    // basic
    let targetClass: AnyClass
    let selector: Selector
    fileprivate let mode: HookMode
    let method: Method
    private var typeContexts: [SHFFITypeContext]
    var shouldSkipHookClosure = false
    
    // signature
    fileprivate let methodSignature: Signature
    fileprivate let closureSignature: Signature
    
    // hook
    fileprivate let hookClosure: AnyObject
    fileprivate let hookClosureInvoke: @convention(c) () -> Void
    private let hookArgumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    private let hookReturnFFIType: UnsafeMutablePointer<ffi_type>
    fileprivate let hookCIFPointer: UnsafeMutablePointer<ffi_cif>
    
    // original
    fileprivate let originalIMP: IMP
    private let originalArgumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    private let originalReturnFFIType: UnsafeMutablePointer<ffi_type>
    fileprivate let originalCIFPointer: UnsafeMutablePointer<ffi_cif>
    
    // closure
    private let closure: UnsafeMutablePointer<ffi_closure>
    let newIMP: IMP
    
    init(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        
        // basic
        self.targetClass = targetClass
        self.selector = selector
        self.mode = mode
        guard let method = getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.method = method
        try Signature.canHookClosureWorksByMethod(closure: hookClosure, method: method, mode: mode)
        self.typeContexts = [SHFFITypeContext]()
        
        // signature
        guard let methodSignature = Signature(method: self.method),
            let closureSignature = Signature(closure: hookClosure) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.methodSignature = methodSignature
        self.closureSignature = closureSignature
        
        // hook
        self.hookClosure = hookClosure
        self.hookClosureInvoke = unsafeBitCast(sh_blockInvoke(self.hookClosure), to: (@convention(c) () -> Void).self)
        
        self.hookArgumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: self.closureSignature.argumentTypes.count)
        for (index, argumentType) in self.closureSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            self.typeContexts.append(typeContext)
            self.hookArgumentTypes[index] = typeContext.ffiType
        }
        
        guard let hookReturnTypeContext = SHFFITypeContext(typeEncoding: self.closureSignature.returnType) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.typeContexts.append(hookReturnTypeContext)
        self.hookReturnFFIType = hookReturnTypeContext.ffiType
        
        self.hookCIFPointer = UnsafeMutablePointer.allocate(capacity: 1)
        guard ffi_prep_cif(
            self.hookCIFPointer,
            FFI_DEFAULT_ABI,
            UInt32(self.closureSignature.argumentTypes.count),
            self.hookReturnFFIType,
            self.hookArgumentTypes.baseAddress) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        
        // original
        self.originalIMP = method_getImplementation(self.method)
        
        self.originalArgumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: self.methodSignature.argumentTypes.count)
        for (index, argumentType) in self.methodSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            self.typeContexts.append(typeContext)
            self.originalArgumentTypes[index] = typeContext.ffiType
        }
        
        guard let returnTypeContext = SHFFITypeContext(typeEncoding: methodSignature.returnType) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.typeContexts.append(returnTypeContext)
        self.originalReturnFFIType = returnTypeContext.ffiType
        
        self.originalCIFPointer = UnsafeMutablePointer.allocate(capacity: 1)
        guard (ffi_prep_cif(
            self.originalCIFPointer,
            FFI_DEFAULT_ABI,
            UInt32(self.methodSignature.argumentTypes.count),
            self.originalReturnFFIType,
            self.originalArgumentTypes.baseAddress)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        
        // closure
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
        guard ffi_prep_closure_loc(
            self.closure,
            self.originalCIFPointer,
            closureCalled,
            Unmanaged.passUnretained(self).toOpaque(),
            UnsafeMutableRawPointer(&newIMP)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        
        // swizzling
        method_setImplementation(self.method, self.newIMP)
    }
    
    deinit {
        method_setImplementation(self.method, self.originalIMP)
        ffi_closure_free(self.closure)
        self.originalCIFPointer.deallocate()
        self.originalArgumentTypes.deallocate()
        self.hookCIFPointer.deallocate()
        self.hookArgumentTypes.deallocate()
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
        return HookManager.shared.cancelHook(context: self)
    }
    
}

// TODO: shouldSkipHookClosure unfinish
