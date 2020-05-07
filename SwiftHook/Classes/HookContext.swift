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
        ffi_call(hookContext.cifPointer, unsafeBitCast(hookContext.hookClosureIMP, to: (@convention(c) () -> Void).self), ret, args)
        ffi_call(hookContext.cifPointer, unsafeBitCast(hookContext.originalIMP, to: (@convention(c) () -> Void).self), ret, args)
    case .after:
        break
    case .instead:
        break
    }
}

// TODO: use manager
private var allHookContext = [HookContext]()

public class HookContext {
    
    private let targetClass: AnyClass
    private let selector: Selector
    fileprivate let mode: HookMode
    private let hookClosure: AnyObject
    private let method: Method
    
    private let methodSignature: Signature
    private let closureSignature: Signature
    
    fileprivate let hookClosureIMP: IMP
    fileprivate let originalIMP: IMP
    private let newIMP: IMP
    private let argumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    fileprivate let cifPointer: UnsafeMutablePointer<ffi_cif>
    private let closure: UnsafeMutablePointer<ffi_closure>
    
    private let typeContexts: [SHFFITypeContext]
    
    private var shouldSkipHookClosure = false
    
    private init(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        self.targetClass = targetClass
        self.selector = selector
        self.mode = mode
        self.hookClosure = hookClosure
        
        // Method
        guard let method = getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.method = method
        
        // Signature
        guard let methodSignature = Signature(method: self.method),
            let closureSignature = Signature(closure: hookClosure) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.methodSignature = methodSignature
        self.closureSignature = closureSignature
        
        // IMP
        self.originalIMP = method_getImplementation(self.method)
        
        // hookClosureIMP
        self.hookClosureIMP = imp_implementationWithBlock(self.hookClosure)
        
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
        
        // swizzling
        method_setImplementation(self.method, self.newIMP)
    }
    
    deinit {
        method_setImplementation(self.method, self.originalIMP)
        imp_removeBlock(self.hookClosureIMP)
        ffi_closure_free(self.closure)
        self.cifPointer.deallocate()
        self.argumentTypes.deallocate()
    }
    
    class func hook(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookContext {
        let hookContext = try HookContext.init(targetClass: targetClass, selector: selector, mode: mode, hookClosure: hookClosure)
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
        guard let currentMethod = getMethodWithoutSearchingSuperClasses(targetClass: self.targetClass, selector: self.selector) else {
            assert(false)
            self.shouldSkipHookClosure = true
            return false
        }
        guard self.method == currentMethod &&
            method_getImplementation(currentMethod) == self.newIMP else {
                self.shouldSkipHookClosure = true
                return false
        }
        allHookContext.removeAll { (hookContext) -> Bool in
            return hookContext === self
        }
        return true
    }
    
    // MARK: This is debug tools.
    
    class func debugToolsGetAllHookContext() -> [HookContext] {
        return allHookContext
    }
}

// TODO: shouldSkipHookClosure unfinish
