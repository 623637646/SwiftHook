//
//  HookContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 27/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
import libffi_iOS

private var associatedInsteadContextHandle: UInt8 = 0

private class InsteadContext {
    let objectPointer: UnsafeMutableRawPointer
    let selectorPointer: UnsafeMutableRawPointer
    var lastInsteadClosure: AnyObject
    init(objectPointer: UnsafeMutableRawPointer, selectorPointer: UnsafeMutableRawPointer, lastInsteadClosure: AnyObject) {
        self.objectPointer = objectPointer
        self.selectorPointer = selectorPointer
        self.lastInsteadClosure = lastInsteadClosure
    }
}

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
    
    let isDynamic = isDynamicClass(targetClass: hookContext.targetClass)
    var beforeHookClosures = hookContext.beforeHookClosures
    var insteadHookClosures = hookContext.insteadHookClosures
    var afterHookClosures = hookContext.afterHookClosures
    if isDynamic {
        unowned(unsafe) let object = argsBuffer[0]!.assumingMemoryBound(to: AnyObject.self).pointee
        let (before, after, instead) = associatedGetClosures(object: object, selector: hookContext.selector)
        beforeHookClosures += before
        insteadHookClosures += instead
        afterHookClosures += after
    }
    
    // preparation for before and after
    var hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?>?
    defer {
        hookArgsBuffer?.deallocate()
    }
    if !beforeHookClosures.isEmpty || !afterHookClosures.isEmpty {
        let nargs = Int(hookContext.beforeAfterCifContext.cif.pointee.nargs)
        hookArgsBuffer = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        if nargs >= 2 {
            for index in 1 ... nargs - 1 {
                hookArgsBuffer![index] = argsBuffer[index + 1]
            }
        }
    }
    
    // before
    for var item in beforeHookClosures.reversed() {
        hookArgsBuffer![0] = withUnsafeMutablePointer(to: &item, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        ffi_call(hookContext.beforeAfterCifContext.cif, unsafeBitCast(sh_blockInvoke(item), to: (@convention(c) () -> Void).self), nil, hookArgsBuffer!.baseAddress)
    }
    
    // instead
    if var lastInstead = insteadHookClosures.last {
        // preparation for instead
        var insteadClosure: (@convention(block) () -> Void) = {}
        sh_setBlockInvoke(insteadClosure, hookContext.insteadClosureContext.targetIMP)
        let insteadContext = InsteadContext.init(objectPointer: argsBuffer[0]!, selectorPointer: argsBuffer[1]!, lastInsteadClosure: lastInstead)
        objc_setAssociatedObject(insteadClosure, &associatedInsteadContextHandle, insteadContext, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let nargs = Int(hookContext.insteadCifContext.cif.pointee.nargs)
        var insteadHookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            insteadHookArgsBuffer.deallocate()
        }
        insteadHookArgsBuffer[0] = withUnsafeMutablePointer(to: &lastInstead, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        insteadHookArgsBuffer[1] = withUnsafeMutablePointer(to: &insteadClosure, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                insteadHookArgsBuffer[index] = argsBuffer[index]
            }
        }
        ffi_call(hookContext.insteadCifContext.cif, unsafeBitCast(sh_blockInvoke(lastInstead), to: (@convention(c) () -> Void).self), ret, insteadHookArgsBuffer.baseAddress)
    } else {
        ffi_call(hookContext.methodCifContext.cif, unsafeBitCast(hookContext.methodOriginalIMP, to: (@convention(c) () -> Void).self), ret, args)
    }
    
    // after
    for var item in afterHookClosures.reversed() {
        hookArgsBuffer![0] = withUnsafeMutablePointer(to: &item, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        ffi_call(hookContext.beforeAfterCifContext.cif, unsafeBitCast(sh_blockInvoke(item), to: (@convention(c) () -> Void).self), nil, hookArgsBuffer!.baseAddress)
    }
}

private func insteadClosureCalledFunction(cif: UnsafeMutablePointer<ffi_cif>?, ret: UnsafeMutableRawPointer?, args: UnsafeMutablePointer<UnsafeMutableRawPointer?>?, userdata: UnsafeMutableRawPointer?) {
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
    guard let insteadContext = objc_getAssociatedObject(dynamicClosure, &associatedInsteadContextHandle) as? InsteadContext else {
        assert(false)
        return
    }
    var insteadHookClosures = hookContext.insteadHookClosures
    if isDynamicClass(targetClass: hookContext.targetClass) {
        unowned(unsafe) let object = UnsafeMutablePointer<AnyObject>(OpaquePointer(insteadContext.objectPointer)).pointee
        insteadHookClosures += associatedGetClosures(object: object, selector: hookContext.selector).instead
    }
    guard let firstHookClosureInList = insteadHookClosures.first else {
        assert(false)
        return
    }
    if insteadContext.lastInsteadClosure === firstHookClosureInList {
        // call original method
        let nargs = Int(hookContext.methodCifContext.cif.pointee.nargs)
        var methodArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            methodArgsBuffer.deallocate()
        }
        methodArgsBuffer[0] = insteadContext.objectPointer
        methodArgsBuffer[1] = insteadContext.selectorPointer
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                methodArgsBuffer[index] = argsBuffer[index - 1]
            }
        }
        ffi_call(hookContext.methodCifContext.cif, unsafeBitCast(hookContext.methodOriginalIMP, to: (@convention(c) () -> Void).self), ret, methodArgsBuffer.baseAddress)
    } else {
        // call next instead hook closure
        guard let lastIndex = insteadHookClosures.lastIndex(where: {$0 === insteadContext.lastInsteadClosure}) else {
            assert(false)
            return
        }
        var previousHookClosure = insteadHookClosures[lastIndex - 1]
        let nargs = Int(hookContext.insteadCifContext.cif.pointee.nargs)
        var hookArgsBuffer: UnsafeMutableBufferPointer<UnsafeMutableRawPointer?> = UnsafeMutableBufferPointer.allocate(capacity: nargs)
        defer {
            hookArgsBuffer.deallocate()
        }
        insteadContext.lastInsteadClosure = previousHookClosure
        hookArgsBuffer[0] = withUnsafeMutablePointer(to: &previousHookClosure, { (p) -> UnsafeMutableRawPointer in
            return UnsafeMutableRawPointer(p)
        })
        hookArgsBuffer[1] = argsBuffer[0]
        if nargs >= 3 {
            for index in 2 ... nargs - 1 {
                hookArgsBuffer[index] = argsBuffer[index - 1]
            }
        }
        ffi_call(hookContext.insteadCifContext.cif, unsafeBitCast(sh_blockInvoke(previousHookClosure), to: (@convention(c) () -> Void).self), ret, hookArgsBuffer.baseAddress)
    }
}

class HookContext {
    
    // basic
    let targetClass: AnyClass
    let selector: Selector
    let method: Method
    
    // hook closure pools
    fileprivate var beforeHookClosures = [AnyObject]()
    fileprivate var insteadHookClosures = [AnyObject]()
    fileprivate var afterHookClosures = [AnyObject]()
    
    // original
    fileprivate let methodCifContext: CifContext
    var methodClosureContext: ClosureContext!
    fileprivate let methodOriginalIMP: IMP
    
    // Before & after
    fileprivate let beforeAfterCifContext: CifContext
    
    // Instead
    fileprivate let insteadCifContext: CifContext
    var insteadClosureContext: ClosureContext!
    
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
        self.methodOriginalIMP = method_getImplementation(self.method)
        self.methodCifContext = try CifContext.init(signature: methodSignature)
        
        // Before & after
        let beforeAfterSignature = Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.removeFirst(2)
            types.insert(.closureTypeValue, at: 0)
            return types
        }(), returnType: methodSignature.returnType, signatureType: .closure)
        self.beforeAfterCifContext = try CifContext.init(signature: beforeAfterSignature)
        
        // Instead
        let insteadSignature = Signature(argumentTypes: {
            var types = methodSignature.argumentTypes
            types.removeFirst(2)
            types.insert(.closureTypeValue, at: 0)
            types.insert(.closureTypeValue, at: 1)
            return types
        }(), returnType: methodSignature.returnType, signatureType: .closure)
        self.insteadCifContext = try CifContext.init(signature: insteadSignature)
        
        // Prep closure
        self.methodClosureContext = try ClosureContext.init(cif: self.methodCifContext.cif, fun: methodCalledFunction, userData: Unmanaged.passUnretained(self).toOpaque())
        
        self.insteadClosureContext = try ClosureContext.init(cif: self.insteadCifContext.cif, fun: insteadClosureCalledFunction, userData: Unmanaged.passUnretained(self).toOpaque())
        
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
