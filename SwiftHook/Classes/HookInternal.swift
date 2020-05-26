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

func internalHook(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
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
    try hookContext.append(hookClosure: hookClosure, mode: mode)
    return HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
}

func internalHook(object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    // create dynamic class for single hook
    let dynamicClass: AnyClass = isDynamicClass(targetClass: baseClass) ? baseClass : try wrapDynamicClass(object: object)
    // hook
    if getMethodWithoutSearchingSuperClasses(targetClass: dynamicClass, selector: selector) == nil {
        try overrideSuperMethod(targetClass: dynamicClass, selector: selector)
    }
    var hookContext: HookContext! = hookContextPool.first(where: { (element) -> Bool in
        element.targetClass == dynamicClass && element.selector == selector
    })
    if hookContext == nil {
        hookContext = try HookContext.init(targetClass: dynamicClass, selector: selector)
        hookContextPool.insert(hookContext)
    }
    var token = HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
    token.hookObject = object
    // set hook closure
    try associatedAppendClosure(object: object, selector: selector, hookClosure: hookClosure, mode: mode)
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
            try associatedRemoveClosure(object: hookObject, selector: hookContext.selector, hookClosure: hookClosure, mode: token.mode)
            if associatedClosuresIsEmpty(object: hookObject) {
                try unwrapDynamicClass(object: hookObject)
                return true
            } else {
                return false
            }
        } else {
            try hookContext.remove(hookClosure: hookClosure, mode: token.mode)
            guard let currentMethod = getMethodWithoutSearchingSuperClasses(targetClass: hookContext.targetClass, selector: hookContext.selector) else {
                assert(false)
                return nil
            }
            guard hookContext.method == currentMethod &&
                method_getImplementation(currentMethod) == hookContext.methodNewIMPPointer.pointee else {
                    return false
            }
            if hookContext.isHoolClosurePoolEmpty() {
                hookContextPool.remove(hookContext)
                return true
            } else {
                return false
            }
        }
    } catch {}
    return nil
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
#endif
