//
//  HookInternal.swift
//  SwiftHook
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

enum HookMode {
    case before
    case after
    case instead
}

private var hookContextPool = Set<HookContext>()

private func getHookContext(targetClass: AnyClass, selector: Selector) throws -> HookContext {
    if getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil {
        try overrideSuperMethod(targetClass: targetClass, selector: selector)
    }
    var hookContext: HookContext! = hookContextPool.first(where: { (element) -> Bool in
        element.targetClass == targetClass && element.selector == selector
    })
    if hookContext == nil {
        hookContext = try HookContext.init(targetClass: targetClass, selector: selector)
        hookContextPool.insert(hookContext)
    }
    return hookContext
}

func internalHook(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
    let hookContext = try getHookContext(targetClass: targetClass, selector: selector)
    try hookContext.append(hookClosure: hookClosure, mode: mode)
    return HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
}

func internalHook(object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    // create dynamic class for specified instance hook
    let targetClass: AnyClass = isDynamicClass(targetClass: baseClass) ? baseClass : try wrapDynamicClass(object: object)
    // hook
    let hookContext = try getHookContext(targetClass: targetClass, selector: selector)
    var token = HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
    token.hookObject = object
    // set hook closure
    try appendHookClosure(object: object, selector: selector, hookClosure: hookClosure, mode: mode)
    // Hook dealloc
    _ = hookDeallocAfterByDelegate(object: object, closure: {
        _ = internalCancelHook(token: token)
        } as @convention(block) () -> Void as AnyObject)
    return token
}

/**
 Cancel hook.
 
 # Case 1: Hook instance
 1. Return true if object is reset to previous class.
 2. Return false if object is not reset to previous class.
 3. Returen nil means some issues like token already canceled.
 
 # Case 2: Hook all instance or hook class method.
 Try to change the Method's IMP from hooked to original and released context.
 But it's dangerous when the current IMP is not previous hooked IMP. In this case. cancelHook() still works fine but the context will not be released.
 1. Return true if the context will be released.
 2. Return false if the context will not be released.
 3. Returen nil means some issues like token already canceled.
 
 # Case 3: Hook after dealloc method for pure Swift Object.
 It doesn't use swizzling. Just add a delegate to object. See "HookDeallocAfterDelegate".
 1. always return nil
 */

func internalCancelHook(token: HookToken) -> Bool? {
    do {
        guard let hookContext = token.hookContext else {
            return nil
        }
        guard let hookClosure = token.hookClosure else {
            return nil
        }
        if isDynamicClass(targetClass: hookContext.targetClass) {
            guard let hookObject = token.hookObject else {
                return nil
            }
            try removeHookClosure(object: hookObject, selector: hookContext.selector, hookClosure: hookClosure, mode: token.mode)
            guard object_getClass(hookObject) == hookContext.targetClass else {
                // Maybe observe by KVO after hook by SwiftHook.
                return false
            }
            guard let isIMPChanged = isIMPChanged(hookContext: hookContext) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            guard !isIMPChanged else {
                return false
            }
            guard isHookClosuresEmpty(object: hookObject) else {
                return false
            }
            try unwrapDynamicClass(object: hookObject)
            return true
        } else {
            try hookContext.remove(hookClosure: hookClosure, mode: token.mode)
            guard let isIMPChanged = isIMPChanged(hookContext: hookContext) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            guard !isIMPChanged else {
                return false
            }
            guard hookContext.isHoolClosurePoolEmpty() else {
                return false
            }
            hookContextPool.remove(hookContext)
            return true
        }
    } catch {
        assert(false)
    }
    return nil
}

/**
 Is IMP changed. return nil if has some error
 */
private func isIMPChanged(hookContext: HookContext) -> Bool? {
    guard let currentMethod = getMethodWithoutSearchingSuperClasses(targetClass: hookContext.targetClass, selector: hookContext.selector) else {
        return nil
    }
    return hookContext.method != currentMethod ||
        method_getImplementation(currentMethod) != hookContext.methodClosureContext.targetIMP
}

// MARK: This is debug tools.
#if DEBUG
func debug_getNormalClassHookContextsCount() -> Int {
    var count = 0
    for item in hookContextPool {
        if !isDynamicClass(targetClass: item.targetClass) {
            count += 1
        }
    }
    return count
}

func debug_getinstancewHookContextsCount() -> Int {
    var count = 0
    for item in hookContextPool {
        if isDynamicClass(targetClass: item.targetClass) {
            count += 1
        }
    }
    return count
}
#endif
