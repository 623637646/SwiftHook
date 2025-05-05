//
//  DynamicClass.swift
//  SwiftHook
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private class DynamicClassContext: Hashable {
    
    static var pool = Set<DynamicClassContext>()
    
    fileprivate let baseClass: AnyClass
    fileprivate let dynamicClass: AnyClass
    private let getClassHookContext: HookContext
    
    fileprivate init(baseClass: AnyClass) throws {
        self.baseClass = baseClass
        // Can't use `let dynamicClassName = "SwiftHook_" + "\(baseClass)"` here because the "\(baseClass)" doesn't contain namespace. There maybe some different class with the same className.
        let dynamicClassName = "SwiftHook_" + NSStringFromClass(baseClass)
        guard let dynamicClass = objc_allocateClassPair(baseClass, dynamicClassName, 0) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        objc_registerClassPair(dynamicClass)
        var deallocateHelper: AnyClass? = dynamicClass
        defer {
            if let deallocateHelper = deallocateHelper {
                objc_disposeClassPair(deallocateHelper)
            }
        }
        // Hook "Get Class"
        let selector = NSSelectorFromString("class")
        if getMethodWithoutSearchingSuperClasses(targetClass: dynamicClass, selector: selector) == nil {
            try overrideSuperMethod(targetClass: dynamicClass, selector: selector)
        }
        getClassHookContext = try HookContext.init(targetClass: dynamicClass, selector: selector, isSpecifiedInstance: true)
        try getClassHookContext.append(hookClosure: {_, _, _ in
            return baseClass
        } as @convention(block) ((AnyObject, Selector) -> AnyClass, AnyObject, Selector) -> AnyClass as AnyObject, mode: .instead)
        self.dynamicClass = dynamicClass
        deallocateHelper = nil
    }
    
    deinit {
        objc_disposeClassPair(dynamicClass)
    }
    
    static func == (lhs: DynamicClassContext, rhs: DynamicClassContext) -> Bool {
        lhs.dynamicClass == rhs.dynamicClass
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(dynamicClass))
    }
}

/**
 Wrap dynamic class to object for specified instance hook. Return new class
 The dynamic class can't be destroy because it's unsafe. Some code may refer to this class.
 */
func wrapDynamicClass(object: AnyObject) throws -> AnyClass {
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard !isDynamicClass(targetClass: baseClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    let existingContext = DynamicClassContext.pool.first { (dynamicClassContext) -> Bool in
        dynamicClassContext.baseClass == baseClass
    }
    let context: DynamicClassContext
    if let existingContext {
        context = existingContext
    } else {
        context = try DynamicClassContext(baseClass: baseClass)
        DynamicClassContext.pool.insert(context)
    }
    object_setClass(object, context.dynamicClass)
    return context.dynamicClass
}

func unwrapDynamicClass(object: AnyObject) throws {
    guard let dynamicClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard isDynamicClass(targetClass: dynamicClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    let firstContext = DynamicClassContext.pool.first { $0.dynamicClass == dynamicClass }
    guard let context = firstContext else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    object_setClass(object, context.baseClass)
}

func isDynamicClass(targetClass: AnyClass) -> Bool {
    // This code performance is very bad.
    //    NSStringFromClass(targetClass).hasPrefix("SwiftHook_")
    
    // This is best performance solution. But Swift has some bugs so can't use it. Refer to: https://stackoverflow.com/q/62027812/9315497
    //    return (objc_getAssociatedObject(targetClass, &associatedDynamicTagHandle) as? Bool) ?? false
    
    // This code performance is bad.
    DynamicClassContext.pool.contains { $0.dynamicClass == targetClass }
}
