//
//  HookManager.swift
//  SwiftHook
//
//  Created by Yanni Wang on 10/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

final class HookManager {
    static let shared = HookManager()
    
    private var allHookContext = [HookContext]()
    private var allOverrideMethodContext = [OverrideMethodContext]()
    
    private init() {
        
    }
    
    func hook(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws -> HookContext {
        if getMethodWithoutSearchingSuperClasses(targetClass: targetClass, selector: selector) == nil {
            try overrideSuperMethod(targetClass: targetClass, selector: selector)
        }
        let hookContext = try HookContext.init(targetClass: targetClass, selector: selector, mode: mode, hookClosure: hookClosure)
        allHookContext.append(hookContext)
        return hookContext
    }
    
    func overrideSuperMethod(targetClass: AnyClass, selector: Selector) throws {
        let overrideMethodContext = try OverrideMethodContext.init(targetClass: targetClass, selector: selector)
        allOverrideMethodContext.append(overrideMethodContext)
    }
    
    func cancelHook(context: HookContext) -> Bool {
        guard let currentMethod = getMethodWithoutSearchingSuperClasses(targetClass: context.targetClass, selector: context.selector) else {
            assert(false)
            context.shouldSkipHookClosure = true
            return false
        }
        guard context.method == currentMethod &&
            method_getImplementation(currentMethod) == context.newIMP else {
                context.shouldSkipHookClosure = true
                return false
        }
        allHookContext.removeAll { (hookContext) -> Bool in
            return hookContext === context
        }
        return true
    }
    
    // MARK: This is debug tools.
    
    func debugToolsGetAllHookContext() -> [HookContext] {
        return allHookContext
    }
        
    func debugToolsGetAllOverrideMethodContext() -> [OverrideMethodContext] {
        return allOverrideMethodContext
    }
    
}
