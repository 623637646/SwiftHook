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

func internalHook(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
    let hookContext = try getHookContext(targetClass: targetClass, selector: selector, isSpecifiedInstance: false)
    try hookContext.append(hookClosure: hookClosure, mode: mode)
    return HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
}

func internalHook(object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
    let targetClass: AnyClass
    if let object = object as? NSObject {
        guard try isSupportedKVO(object: object) else {
            throw SwiftHookError.hookKVOUnsupportedInstance
        }
        // use KVO for specified instance hook
        try wrapKVOIfNeeded(object: object, selector: selector)
        guard let KVOedClass = object_getClass(object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        targetClass = KVOedClass
    } else {
        // create dynamic class for specified instance hook
        guard let baseClass = object_getClass(object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        targetClass = isDynamicClass(targetClass: baseClass) ? baseClass : try wrapDynamicClass(object: object)
    }
    // hook
    let hookContext = try getHookContext(targetClass: targetClass, selector: selector, isSpecifiedInstance: true)
    var token = HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
    token.hookObject = object
    // set hook closure
    try appendHookClosure(object: object, selector: selector, hookClosure: hookClosure, mode: mode)
    return token
}

/**
 Cancel hook.
 
 # Case 1: Hook instance
 1. Return true if object has tried to reset to previous class.
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

func internalCancelHook(token: HookToken) throws -> Bool? {
    guard let hookContext = token.hookContext else {
        // This token has been cancelled.
        return nil
    }
    if hookContext.isSpecifiedInstance {
        // This hook is for specified instance
        guard let hookObject = token.hookObject else {
            // The object has been deinit.
            return nil
        }
        guard let hookClosure = token.hookClosure else {
            // Token has been canceled.
            return nil
        }
        try removeHookClosure(object: hookObject, selector: hookContext.selector, hookClosure: hookClosure, mode: token.mode)
        
        guard object_getClass(hookObject) == hookContext.targetClass else {
            // The class is changed after hooking by SwiftHook.
            return false
        }
        guard !(try isIMPChanged(hookContext: hookContext)) else {
            // The IMP is changed after hooking by SwiftHook.
            return false
        }
        guard isHookClosuresEmpty(object: hookObject) else {
            // There are still some hooks on this object.
            return false
        }
        if let object = hookObject as? NSObject {
            unwrapKVOIfNeeded(object: object)
        } else {
            try unwrapDynamicClass(object: hookObject)
        }
        // Can't call `removeHookContext(hookContext: hookContext)` to remove the hookContext because we don't know if there are any objects needed this hookContext
        return true
    } else {
        // This hook is for all instance or class method
        guard let hookClosure = token.hookClosure else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try hookContext.remove(hookClosure: hookClosure, mode: token.mode)
        guard !(try isIMPChanged(hookContext: hookContext)) else {
            // The IMP is changed after hooking by SwiftHook.
            return false
        }
        guard hookContext.isHoolClosurePoolEmpty() else {
            // There are still some hooks on this hookContext.
            return false
        }
        removeHookContext(hookContext: hookContext)
        return true
    }
}

/**
 Is IMP changed. return nil if has some error
 */
private func isIMPChanged(hookContext: HookContext) throws -> Bool {
    guard let currentMethod = getMethodWithoutSearchingSuperClasses(targetClass: hookContext.targetClass, selector: hookContext.selector) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return hookContext.method != currentMethod ||
        method_getImplementation(currentMethod) != hookContext.methodClosureContext.targetIMP
}
