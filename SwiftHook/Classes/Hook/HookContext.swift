//
//  HookContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 27/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import libffi_iOS
#if SWIFT_PACKAGE
import SwiftHookOCSources
#endif

private func methodCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?, ret: UnsafeMutableRawPointer?, args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, userdata: UnsafeMutableRawPointer?) {
    
    // Parameters
    guard let userdata = userdata, let cif = cif else {
        assert(false)
        return
    }
    let hookContext = Unmanaged<HookContext>.fromOpaque(userdata).takeUnretainedValue()
    let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: Int(cif.pointee.nargs))
    
    // Get instead hook closures.
    var insteadHookClosures = hookContext.insteadHookClosures
    if hookContext.isSpecifiedInstance {
        let objectPointer = argsBuffer[0]!
        unowned(unsafe) let object = objectPointer.assumingMemoryBound(to: AnyObject.self).pointee
        insteadHookClosures += getHookClosures(object: object, selector: hookContext.selector).instead
    }
    
    // instead
    if var hookClosure = insteadHookClosures.last {
        // preparation for instead
        var insteadClosure = createInsteadClosure(targetIMP: hookContext.insteadClosureContext.targetIMP, objectPointer: argsBuffer[0]!, selectorPointer: argsBuffer[1]!, currentHookClosure: hookClosure)
        let nargs = Int(hookContext.insteadCifContext.cif.pointee.nargs)
        let insteadHookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            insteadHookArgsBuffer.deallocate()
        }
        insteadHookArgsBuffer[0] = withUnsafeMutablePointer(to: &hookClosure, {UnsafeMutableRawPointer($0)})
        insteadHookArgsBuffer[1] = withUnsafeMutablePointer(to: &insteadClosure, {UnsafeMutableRawPointer($0)})
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                insteadHookArgsBuffer[index] = argsBuffer[index - 2]
            }
        }
        ffi_call(hookContext.insteadCifContext.cif, unsafeBitCast(sh_blockInvoke(hookClosure), to: (@convention(c) () -> Void).self), ret, insteadHookArgsBuffer.baseAddress)
    } else {
        callBeforeHookClosuresAndOriginalMethodAndAfterHookClosures(hookContext: hookContext, ret: ret, argsBuffer: argsBuffer)
    }
}

private func insteadClosureCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?, ret: UnsafeMutableRawPointer?, args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, userdata: UnsafeMutableRawPointer?) {
    
    // Parameters
    guard let userdata = userdata, let cif = cif else {
        assert(false)
        return
    }
    let hookContext = Unmanaged<HookContext>.fromOpaque(userdata).takeUnretainedValue()
    let argsBuffer = UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>(start: args, count: Int(cif.pointee.nargs))
    let insteadClosurePointer = argsBuffer[0]!
    unowned(unsafe) let insteadClosure = insteadClosurePointer.assumingMemoryBound(to: AnyObject.self).pointee
    guard let insteadContext = getInsteadContext(insteadClosure: insteadClosure) else {
        assert(false)
        return
    }
    
    // Get instead hook closures.
    var insteadHookClosures = hookContext.insteadHookClosures
    if hookContext.isSpecifiedInstance {
        let objectPointer = hookContext.isHookingDealloc ? insteadContext.objectPointer : argsBuffer[1]!
        unowned(unsafe) let object = objectPointer.assumingMemoryBound(to: AnyObject.self).pointee
        insteadHookClosures += getHookClosures(object: object, selector: hookContext.selector).instead
    }
    
    // "insteadHookClosures.first == nil" is for object changing. If user change the object (First parameter). The "insteadHookClosures.first" may be nil.
    if insteadHookClosures.first == nil ||
        insteadContext.currentHookClosure === insteadHookClosures.first {
        // call original method
        let nargs = Int(hookContext.methodCifContext.cif.pointee.nargs)
        let methodArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            methodArgsBuffer.deallocate()
        }
        if hookContext.isHookingDealloc {
            methodArgsBuffer[0] = insteadContext.objectPointer
            methodArgsBuffer[1] = insteadContext.selectorPointer
        } else {
            for index in 0 ... nargs - 1 {
                methodArgsBuffer[index] = argsBuffer[index + 1]
            }
        }
        callBeforeHookClosuresAndOriginalMethodAndAfterHookClosures(hookContext: hookContext, ret: ret, argsBuffer: methodArgsBuffer)
    } else {
        // call next instead hook closure
        guard let lastIndex = insteadHookClosures.lastIndex(where: {$0 === insteadContext.currentHookClosure}) else {
            assert(false)
            return
        }
        var hookClosure = insteadHookClosures[lastIndex - 1]
        let nargs = Int(hookContext.insteadCifContext.cif.pointee.nargs)
        let hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            hookArgsBuffer.deallocate()
        }
        hookArgsBuffer[0] = withUnsafeMutablePointer(to: &hookClosure, {UnsafeMutableRawPointer($0)})
        hookArgsBuffer[1] = insteadClosurePointer
        for index in 2 ... nargs - 1 {
            hookArgsBuffer[index] = argsBuffer[index - 1]
        }
        insteadContext.currentHookClosure = hookClosure
        ffi_call(hookContext.insteadCifContext.cif, unsafeBitCast(sh_blockInvoke(hookClosure), to: (@convention(c) () -> Void).self), ret, hookArgsBuffer.baseAddress)
    }
}

private func callBeforeHookClosuresAndOriginalMethodAndAfterHookClosures(hookContext: HookContext, ret: UnsafeMutableRawPointer?, argsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>) {
    
    // Get before and after hook closures.
    var beforeHookClosures = hookContext.beforeHookClosures
    var afterHookClosures = hookContext.afterHookClosures
    if hookContext.isSpecifiedInstance {
        let objectPointer = argsBuffer[0]!
        unowned(unsafe) let object = objectPointer.assumingMemoryBound(to: AnyObject.self).pointee
        let (before, after, _) = getHookClosures(object: object, selector: hookContext.selector)
        beforeHookClosures += before
        afterHookClosures += after
    }
    
    // preparation argsBuffer
    var hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>?
    defer {
        hookArgsBuffer?.deallocate()
    }
    if !beforeHookClosures.isEmpty || !afterHookClosures.isEmpty {
        let nargs = Int(hookContext.beforeAfterCifContext.cif.pointee.nargs)
        hookArgsBuffer = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        if nargs >= 2 {
            for index in 1 ... nargs - 1 {
                hookArgsBuffer![index] = argsBuffer[index - 1]
            }
        }
    }
    
    // call before closures.
    for hookClosure in beforeHookClosures.reversed() {
        callBeforeOrAfterClosure(hookClosure, hookContext, hookArgsBuffer!)
    }
    
    // call original
    ffi_call(hookContext.methodCifContext.cif, unsafeBitCast(hookContext.methodOriginalIMP, to: (@convention(c) () -> Void).self), ret, argsBuffer.baseAddress)
    
    // call after closures.
    for hookClosure in afterHookClosures.reversed() {
        callBeforeOrAfterClosure(hookClosure, hookContext, hookArgsBuffer!)
    }
}

private func callBeforeOrAfterClosure(_ hookClosure: AnyObject, _ hookContext: HookContext, _ hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>) {
    var hookClosure = hookClosure
    hookArgsBuffer[0] = withUnsafeMutablePointer(to: &hookClosure, {UnsafeMutableRawPointer($0)})
    ffi_call(hookContext.beforeAfterCifContext.cif, unsafeBitCast(sh_blockInvoke(hookClosure), to: (@convention(c) () -> Void).self), nil, hookArgsBuffer.baseAddress)
}

class HookContext {
    
    // basic
    let targetClass: AnyClass
    let selector: Selector
    let method: Method
    let isSpecifiedInstance: Bool
    let isHookingDealloc: Bool
    
    // hook closure pools
    fileprivate var beforeHookClosures = [AnyObject]()
    fileprivate var insteadHookClosures = [AnyObject]()
    fileprivate var afterHookClosures = [AnyObject]()
    
    // original
    fileprivate let methodCifContext: FFICIFContext
    var methodClosureContext: FFIClosureContext!
    fileprivate let methodOriginalIMP: IMP
    
    // Before & after
    fileprivate let beforeAfterCifContext: FFICIFContext

    // Instead
    fileprivate let insteadCifContext: FFICIFContext
    fileprivate let insteadClosureCifContext: FFICIFContext
    fileprivate var insteadClosureContext: FFIClosureContext!

    init(targetClass: AnyClass, selector: Selector, isSpecifiedInstance: Bool) throws {
        // basic
        self.targetClass = targetClass
        self.selector = selector
        self.isSpecifiedInstance = isSpecifiedInstance

        guard let method = getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.method = method
        self.isHookingDealloc = selector == deallocSelector
        
        // original
        let methodSignature = try Signature(method: self.method)
        self.methodOriginalIMP = method_getImplementation(self.method)
        self.methodCifContext = try FFICIFContext.init(signature: methodSignature)
        
        // Before & after
        self.beforeAfterCifContext = try FFICIFContext.init(signature: Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.insert(.closureTypeValue, at: 0)
            return types
        }(), returnType: .voidTypeValue, signatureType: .closure))
        
        // Instead
        self.insteadCifContext = try FFICIFContext.init(signature: Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.insert(.closureTypeValue, at: 0)
            types.insert(.closureTypeValue, at: 1)
            return types
        }(), returnType: methodSignature.returnType, signatureType: .closure))
        
        self.insteadClosureCifContext = try FFICIFContext.init(signature: Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.insert(.closureTypeValue, at: 0)
            return types
        }(), returnType: methodSignature.returnType, signatureType: .closure))
        
        // Prep closure
        self.methodClosureContext = try FFIClosureContext.init(cif: self.methodCifContext.cif, fun: methodCalledFunction, userData: Unmanaged.passUnretained(self).toOpaque())
        
        self.insteadClosureContext = try FFIClosureContext.init(cif: self.insteadClosureCifContext.cif, fun: insteadClosureCalledFunction, userData: Unmanaged.passUnretained(self).toOpaque())
        
        // swizzling
        method_setImplementation(self.method, self.methodClosureContext.targetIMP)
    }
    
    deinit {
        method_setImplementation(self.method, self.methodOriginalIMP)
    }
    
    func append(hookClosure: AnyObject, mode: HookMode) throws {
        switch mode {
        case .before:
            guard !beforeHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.duplicateHookClosure
            }
            beforeHookClosures.append(hookClosure)
        case .after:
            guard !afterHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.duplicateHookClosure
            }
            afterHookClosures.append(hookClosure)
        case .instead:
            guard !insteadHookClosures.contains(where: {
                hookClosure  === $0
            }) else {
                throw SwiftHookError.duplicateHookClosure
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

private var hookContextPool = Set<HookContext>()

func getHookContext(targetClass: AnyClass, selector: Selector, isSpecifiedInstance: Bool) throws -> HookContext {
    if getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil {
        try overrideSuperMethod(targetClass: targetClass, selector: selector)
    }
    var hookContext: HookContext! = hookContextPool.first(where: { (element) -> Bool in
        element.targetClass == targetClass && element.selector == selector
    })
    if hookContext == nil {
        hookContext = try HookContext.init(targetClass: targetClass, selector: selector, isSpecifiedInstance: isSpecifiedInstance)
        hookContextPool.insert(hookContext)
    }
    return hookContext
}

func removeHookContext(hookContext: HookContext) {
    hookContextPool.remove(hookContext)
}

// MARK: This is debug tools.
#if DEBUG
func debug_getNormalClassHookContextsCount() -> Int {
    var count = 0
    for item in hookContextPool where !item.isSpecifiedInstance {
        count += 1
    }
    return count
}

func debug_getinstancewHookContextsCount() -> Int {
    var count = 0
    for item in hookContextPool where item.isSpecifiedInstance {
        count += 1
    }
    return count
}
#endif
