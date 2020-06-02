//
//  OverrideMethodContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 5/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private func overrideMethodCalled(cif: UnsafeMutablePointer<ffi_cif>?,
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
    guard let methodIMP = class_getMethodImplementation(sueprClass, overrideMethodContext.selector) else {
        assert(false)
        return
    }
    ffi_call(overrideMethodContext.methodCifContext.cif, unsafeBitCast(methodIMP, to: (@convention(c) () -> Void).self), ret, args)
}

private var overrideMethodContextPool = Set<OverrideMethodContext>()

private class OverrideMethodContext: Hashable {
    
    fileprivate let targetClass: AnyClass
    fileprivate let selector: Selector
    
    fileprivate let methodCifContext: CifContext
    fileprivate var methodClosureContext: ClosureContext!
    
    init(targetClass: AnyClass, selector: Selector) throws {
        self.targetClass = targetClass
        self.selector = selector
        
        // Check self Method
        guard getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil else {
            // Tests: OverrideSuperMethodTests: testSelfExistingMethod
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        
        // superMethod
        guard let superMethod = class_getInstanceMethod(self.targetClass, self.selector) else {
            // Tests: OverrideSuperMethodTests: testCanNotGetMethod
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        
        // Signature
        guard let methodSignature = Signature(method: superMethod) else {
            throw SwiftHookError.missingSignature
        }
        
        // CifContext
        self.methodCifContext = try CifContext.init(signature: methodSignature)
        
        // ClosureContext
        self.methodClosureContext = try ClosureContext.init(cif: self.methodCifContext.cif, fun: overrideMethodCalled, userData: Unmanaged.passUnretained(self).toOpaque())
        
        // add Method
        guard class_addMethod(self.targetClass, self.selector, self.methodClosureContext.targetIMP, method_getTypeEncoding(superMethod)) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
    }
    
    // MARK: Hashable
    
    static func == (lhs: OverrideMethodContext, rhs: OverrideMethodContext) -> Bool {
        lhs.targetClass == rhs.targetClass && lhs.selector == rhs.selector
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(targetClass))
        hasher.combine(selector)
    }
}

func overrideSuperMethod(targetClass: AnyClass, selector: Selector) throws {
    let overrideMethodContext = try OverrideMethodContext.init(targetClass: targetClass, selector: selector)
    overrideMethodContextPool.insert(overrideMethodContext)
}

// MARK: This is debug tools.

#if DEBUG
func debug_overrideMethodContextCount() -> Int {
    return overrideMethodContextPool.count
}
#endif
