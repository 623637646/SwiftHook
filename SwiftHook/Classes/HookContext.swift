//
//  HookContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 27/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import libffi_iOS

private var associatedInsteadClosureHandle: UInt8 = 0
private var associatedArg0Handle: UInt8 = 0
private var associatedArg1Handle: UInt8 = 0

private func methodCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?,
                                  ret: UnsafeMutableRawPointer?,
                                  args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                                  userdata: UnsafeMutableRawPointer?) {
    guard let userdata = userdata, let cif = cif else {
        assert(false)
        return
    }
    let hookContext = Unmanaged<HookContext>.fromOpaque(userdata).takeUnretainedValue()
    let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: Int(cif.pointee.nargs))
    
    // preparation for before and after
    var hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>?
    defer {
        hookArgsBuffer?.deallocate()
    }
    if !hookContext.beforeHookClosures.isEmpty || !hookContext.afterHookClosures.isEmpty {
        let nargs = Int(hookContext.hookCif.pointee.nargs)
        hookArgsBuffer = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        if nargs >= 2 {
            for index in 1 ... nargs - 1 {
                hookArgsBuffer![index] = argsBuffer[index + 1]
            }
        }
    }
    
    // before
    for var item in hookContext.beforeHookClosures.reversed() {
        hookArgsBuffer![0] = UnsafeMutableRawPointer(&item)
        ffi_call(hookContext.hookCif, unsafeBitCast(sh_blockInvoke(item), to: (@convention(c) () -> Void).self), nil, hookArgsBuffer!.baseAddress)
    }
    
    // instead
    if var lastInstead = hookContext.insteadHookClosures.last {
        // preparation for instead
        var insteadClosure: (@convention(block) () -> Void) = {}
        sh_setBlockInvoke(insteadClosure, OpaquePointer(hookContext.blockInvoke.pointee!))
        let object = argsBuffer[0]!.assumingMemoryBound(to: AnyObject.self).pointee
        let selectorString = NSStringFromSelector(argsBuffer[1]!.assumingMemoryBound(to: Selector.self).pointee)
        objc_setAssociatedObject(insteadClosure, &associatedInsteadClosureHandle, lastInstead, .OBJC_ASSOCIATION_ASSIGN)
        objc_setAssociatedObject(insteadClosure, &associatedArg0Handle, object, .OBJC_ASSOCIATION_ASSIGN)
        objc_setAssociatedObject(insteadClosure, &associatedArg1Handle, selectorString, .OBJC_ASSOCIATION_ASSIGN)
        
        let nargs = Int(hookContext.insteadHookCif.pointee.nargs)
        var insteadHookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            insteadHookArgsBuffer.deallocate()
        }
        insteadHookArgsBuffer[0] = UnsafeMutableRawPointer(&lastInstead)
        insteadHookArgsBuffer[1] = UnsafeMutableRawPointer(&insteadClosure)
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                insteadHookArgsBuffer[index] = argsBuffer[index]
            }
        }
        ffi_call(hookContext.insteadHookCif, unsafeBitCast(sh_blockInvoke(lastInstead), to: (@convention(c) () -> Void).self), ret, insteadHookArgsBuffer.baseAddress)
    } else {
        ffi_call(hookContext.methodCif, unsafeBitCast(hookContext.methodIMP, to: (@convention(c) () -> Void).self), ret, args)
    }
    
    // after
    for var item in hookContext.afterHookClosures.reversed() {
        hookArgsBuffer![0] = UnsafeMutableRawPointer(&item)
        ffi_call(hookContext.hookCif, unsafeBitCast(sh_blockInvoke(item), to: (@convention(c) () -> Void).self), nil, hookArgsBuffer!.baseAddress)
    }
}

private func insteadHookClosureCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?,
                                              ret: UnsafeMutableRawPointer?,
                                              args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
                                              userdata: UnsafeMutableRawPointer?) {
    guard let userdata = userdata, let cif = cif else {
        assert(false)
        return
    }
    let hookContext = Unmanaged<HookContext>.fromOpaque(userdata).takeUnretainedValue()
    let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: Int(cif.pointee.nargs))
    guard let dynamicClosure = UnsafeMutablePointer<AnyObject>(OpaquePointer(argsBuffer[0]))?.pointee else {
        assert(false)
        return
    }
    guard let lastHookClosure = objc_getAssociatedObject(dynamicClosure, &associatedInsteadClosureHandle) as AnyObject? else {
        assert(false)
        return
    }
    guard let firstHookClosureInList = hookContext.insteadHookClosures.first else {
        assert(false)
        return
    }
    if lastHookClosure === firstHookClosureInList {
        // call original method
        let nargs = Int(hookContext.methodCif.pointee.nargs)
        var methodArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            methodArgsBuffer.deallocate()
        }
        guard var object = objc_getAssociatedObject(dynamicClosure, &associatedArg0Handle) as AnyObject?,
            let selectorString = objc_getAssociatedObject(dynamicClosure, &associatedArg1Handle) as? String
            else {
                assert(false)
                return
        }
        var selector = NSSelectorFromString(selectorString as String)
        methodArgsBuffer[0] = UnsafeMutableRawPointer(&object)
        methodArgsBuffer[1] = UnsafeMutableRawPointer(&selector)
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                methodArgsBuffer[index] = argsBuffer[index - 1]
            }
        }
        ffi_call(hookContext.methodCif, unsafeBitCast(hookContext.methodIMP, to: (@convention(c) () -> Void).self), ret, methodArgsBuffer.baseAddress)
    } else {
        // call next instead hook closure
        guard let lastIndex = hookContext.insteadHookClosures.lastIndex(where: {$0 === lastHookClosure}) else {
            assert(false)
            return
        }
        var previousHookClosure = hookContext.insteadHookClosures[lastIndex - 1]
        let nargs = Int(hookContext.insteadHookCif.pointee.nargs)
        var hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            hookArgsBuffer.deallocate()
        }
        objc_setAssociatedObject(dynamicClosure, &associatedInsteadClosureHandle, previousHookClosure, .OBJC_ASSOCIATION_ASSIGN)
        hookArgsBuffer[0] = UnsafeMutableRawPointer(&previousHookClosure)
        hookArgsBuffer[1] = argsBuffer[0]
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                hookArgsBuffer[index] = argsBuffer[index - 1]
            }
        }
        ffi_call(hookContext.insteadHookCif, unsafeBitCast(sh_blockInvoke(previousHookClosure), to: (@convention(c) () -> Void).self), ret, hookArgsBuffer.baseAddress)
    }
}

class HookContext {
    
    // basic
    let targetClass: AnyClass
    let selector: Selector
    let method: Method
    private var typeContexts = Set<SHFFITypeContext>()
    
    // hook closure pools
    fileprivate var beforeHookClosures = [AnyObject]()
    fileprivate var insteadHookClosures = [AnyObject]()
    fileprivate var afterHookClosures = [AnyObject]()
    
    // original
    fileprivate let methodIMP: IMP
    private let methodArgTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    private let methodReturnType: UnsafeMutablePointer<ffi_type>
    fileprivate let methodCif: UnsafeMutablePointer<ffi_cif>
    private let methodFFIClosure: UnsafeMutablePointer<ffi_closure>
    let methodNewIMPPointer: UnsafeMutablePointer<IMP> = UnsafeMutablePointer.allocate(capacity: 1)

    // Before & after
    private let hookArgTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    private let hookReturnType: UnsafeMutablePointer<ffi_type>
    fileprivate let hookCif: UnsafeMutablePointer<ffi_cif>
    
    // Instead
    private let insteadHookArgTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>
    private let insteadHookReturnType: UnsafeMutablePointer<ffi_type>
    fileprivate let insteadHookCif: UnsafeMutablePointer<ffi_cif>
    private let insteadHookFFIClosure: UnsafeMutablePointer<ffi_closure>
    fileprivate let blockInvoke = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 1)
    
    init(targetClass: AnyClass, selector: Selector) throws {
        
        // basic
        self.targetClass = targetClass
        self.selector = selector
        guard let method = getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.method = method
        
        // original
        guard let methodSignature = Signature(method: self.method) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.methodIMP = method_getImplementation(self.method)
        self.methodArgTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: methodSignature.argumentTypes.count)
        for (index, argumentType) in methodSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            self.typeContexts.insert(typeContext)
            self.methodArgTypes[index] = typeContext.ffiType
        }
        guard let methodReturnTypeContext = SHFFITypeContext(typeEncoding: methodSignature.returnType) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.typeContexts.insert(methodReturnTypeContext)
        self.methodReturnType = methodReturnTypeContext.ffiType
        self.methodCif = UnsafeMutablePointer.allocate(capacity: 1)
        guard (ffi_prep_cif(
            self.methodCif,
            FFI_DEFAULT_ABI,
            UInt32(methodSignature.argumentTypes.count),
            self.methodReturnType,
            self.methodArgTypes.baseAddress)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        self.methodFFIClosure = ffi_closure_alloc(
            MemoryLayout<ffi_closure>.stride,
            self.methodNewIMPPointer.withMemoryRebound(to: UnsafeMutableRawPointer?.self, capacity: 1, {$0})).assumingMemoryBound(to: ffi_closure.self)
        
        // Before & after
        let hookSignature = Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.removeFirst(2)
            types.insert("@?", at: 0)
            return types
        }(), returnType: methodSignature.returnType, signatureType: .closure)
        self.hookArgTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: hookSignature.argumentTypes.count)
        for (index, argumentType) in hookSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            self.typeContexts.insert(typeContext)
            self.hookArgTypes[index] = typeContext.ffiType
        }
        guard let hookClosureReturnTypeContext = SHFFITypeContext(typeEncoding: hookSignature.returnType) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.typeContexts.insert(hookClosureReturnTypeContext)
        self.hookReturnType = hookClosureReturnTypeContext.ffiType
        self.hookCif = UnsafeMutablePointer.allocate(capacity: 1)
        guard (ffi_prep_cif(
            self.hookCif,
            FFI_DEFAULT_ABI,
            UInt32(hookSignature.argumentTypes.count),
            self.hookReturnType,
            self.hookArgTypes.baseAddress)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        
        // Instead
        let insteadHookSignature = Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.removeFirst(2)
            types.insert("@?", at: 0)
            types.insert("@?", at: 1)
            return types
        }(), returnType: methodSignature.returnType, signatureType: .closure)
        self.insteadHookArgTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: insteadHookSignature.argumentTypes.count)
        for (index, argumentType) in insteadHookSignature.argumentTypes.enumerated() {
            guard let typeContext = SHFFITypeContext(typeEncoding: argumentType) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            self.typeContexts.insert(typeContext)
            self.insteadHookArgTypes[index] = typeContext.ffiType
        }
        guard let insteadHookClosureReturnTypeContext = SHFFITypeContext(typeEncoding: insteadHookSignature.returnType) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.typeContexts.insert(insteadHookClosureReturnTypeContext)
        self.insteadHookReturnType = insteadHookClosureReturnTypeContext.ffiType
        self.insteadHookCif = UnsafeMutablePointer.allocate(capacity: 1)
        guard (ffi_prep_cif(
            self.insteadHookCif,
            FFI_DEFAULT_ABI,
            UInt32(insteadHookSignature.argumentTypes.count),
            self.insteadHookReturnType,
            self.insteadHookArgTypes.baseAddress)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        self.insteadHookFFIClosure = ffi_closure_alloc(MemoryLayout<ffi_closure>.stride, UnsafeMutablePointer(blockInvoke)).assumingMemoryBound(to: ffi_closure.self)

        // Prep closure
        guard ffi_prep_closure_loc(
            self.methodFFIClosure,
            self.methodCif,
            methodCalledFunction,
            Unmanaged.passUnretained(self).toOpaque(),
            self.methodNewIMPPointer) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        guard ffi_prep_closure_loc(
            self.insteadHookFFIClosure,
            self.hookCif,
            insteadHookClosureCalledFunction,
            Unmanaged.passUnretained(self).toOpaque(),
            UnsafeMutablePointer(blockInvoke)) == FFI_OK else {
                throw SwiftHookError.ffiError
        }
        
        // swizzling
        method_setImplementation(self.method, self.methodNewIMPPointer.pointee)
    }
    
    deinit {
        method_setImplementation(self.method, self.methodIMP)
        self.blockInvoke.deallocate()
        ffi_closure_free(self.insteadHookFFIClosure)
        ffi_closure_free(self.methodFFIClosure)
        self.insteadHookCif.deallocate()
        self.insteadHookArgTypes.deallocate()
        self.hookCif.deallocate()
        self.hookArgTypes.deallocate()
        self.methodNewIMPPointer.deallocate()
        self.methodCif.deallocate()
        self.methodArgTypes.deallocate()
    }
    
    func append(hookClosure: AnyObject, mode: HookMode) throws {
        switch mode {
        case .before:
            guard !beforeHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            beforeHookClosures.append(hookClosure)
        case .after:
            guard !afterHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            afterHookClosures.append(hookClosure)
        case .instead:
            guard !insteadHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            insteadHookClosures.append(hookClosure)
        }
    }
    
    func remove(hookClosure: AnyObject, mode: HookMode) throws {
        switch mode {
        case .before:
            guard beforeHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            beforeHookClosures.removeAll {
                hookClosure  === $0
            }
        case .after:
            guard afterHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            afterHookClosures.removeAll {
                hookClosure  === $0
            }
        case .instead:
            guard insteadHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            insteadHookClosures.removeAll {
                hookClosure  === $0
            }
        }
    }
    
    func isHoolClosurePoolEmpty() -> Bool {
        beforeHookClosures.isEmpty && insteadHookClosures.isEmpty && afterHookClosures.isEmpty
    }
}

extension HookContext: Hashable {
    static func == (lhs: HookContext, rhs: HookContext) -> Bool {
        lhs.targetClass == rhs.targetClass && lhs.selector == rhs.selector
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(targetClass))
        hasher.combine(selector)
    }
}

// TODO: 对hook后执行的代码优化。无需优化hook方法
