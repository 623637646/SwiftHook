//
//  HookManager.swift
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

final class HookManager {
    static let shared = HookManager()
    
    private var hookContextPool = Set<HookContext>()
    
    private init() {}
    
    func hook(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
        try parametersCheck(targetClass: targetClass, selector: selector, mode: mode, closure: hookClosure)
        if getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil {
            try overrideSuperMethod(targetClass: targetClass, selector: selector)
        }
        var hookContext: HookContext!
        if !self.hookContextPool.contains(where: { (element) -> Bool in
            guard element.targetClass == targetClass && element.selector == selector else {
                return false
            }
            hookContext = element
            return true
        }) {
            hookContext = try HookContext.init(targetClass: targetClass, selector: selector)
            self.hookContextPool.insert(hookContext)
        }
        try hookContext.append(hookClosure: hookClosure, mode: mode)
        return HookToken(hookContext: hookContext, hookClosure: hookClosure, mode: mode)
    }
    
    // TODO: 如果 object 或者 hookClosure 释放了；应该取消hook!
    func hook(object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookToken {
        try parametersCheck(targetClass: type(of: object), selector: selector, mode: mode, closure: hookClosure)
        // create dynamic class for single hook
        let dynamicClass: AnyClass = try wrapDynamicClass(object: object, hookClosure: hookClosure)
        return try hook(targetClass: dynamicClass, selector: selector, mode: mode, hookClosure: hookClosure)
    }
    
    // TODO: test cases for cancelHook again.
    @discardableResult
    func cancelHook(token: HookToken) -> Bool? {
        do {
            guard let hookContext = token.hookContext else {
                return nil
            }
            guard let hookClosure = token.hookClosure else {
                return nil
            }
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
                self.hookContextPool.remove(hookContext)
                return true
            } else {
                return false
            }
        } catch {}
        return nil
    }
    
    private func parametersCheck(targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
        // TODO: Selector black list.
        if selector == deallocSelector {
            guard targetClass is NSObject.Type else {
                throw SwiftHookError.unsupport(type: .hookSwiftObjectDealloc)
            }
            guard mode != .instead else {
                throw SwiftHookError.unsupport(type: .insteadHookNSObjectDealloc)
            }
        }
        
        guard let method = class_getInstanceMethod(targetClass, selector) else {
            throw SwiftHookError.noRespondSelector(targetClass: targetClass, selector: selector)
        }
        try Signature.canHookClosureWorksByMethod(closure: closure, method: method, mode: mode)
    }
    
    // MARK: This is debug tools.
    // TODO: 优化
    
    func debugToolsGetAllHookContext() -> Set<HookContext> {
        return hookContextPool
    }
}
