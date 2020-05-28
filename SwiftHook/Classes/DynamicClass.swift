//
//  DynamicClass.swift
//  SwiftHook
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private let prefix = "SwiftHook_"
private var dynamicClassContextPool = Set<DynamicClassContext>()

private class DynamicClassContext: Hashable {
    
    fileprivate let baseClass: AnyClass
    fileprivate let dynamicClass: AnyClass
    private let getClassHookContext: HookContext
    
    fileprivate init(baseClass: AnyClass) throws {
        self.baseClass = baseClass
        let dynamicClassName = prefix + "\(baseClass)"
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
        getClassHookContext = try HookContext.init(targetClass: dynamicClass, selector: selector)
        try getClassHookContext.append(hookClosure: {_ in
            return baseClass
            } as @convention(block) (() -> AnyClass) -> AnyClass as AnyObject, mode: .instead)
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
 */
func wrapDynamicClass(object: AnyObject) throws -> AnyClass {
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard !isDynamicClass(targetClass: baseClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    var context: DynamicClassContext! = dynamicClassContextPool.first { (dynamicClassContext) -> Bool in
        dynamicClassContext.baseClass == baseClass
    }
    if context == nil {
        context = try DynamicClassContext.init(baseClass: baseClass)
        dynamicClassContextPool.insert(context)
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
    let firstContext = dynamicClassContextPool.first { (dynamicClassContext) -> Bool in
        dynamicClassContext.dynamicClass == dynamicClass
    }
    guard let context = firstContext else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    object_setClass(object, context.baseClass)
}

func isDynamicClass(targetClass: AnyClass) -> Bool {
    // This code performance is very bad.
    //    NSStringFromClass(targetClass).hasPrefix(prefix)
    
    // This is best performance solution. But Swift has some bugs so can't use it. Refer to: https://stackoverflow.com/q/62027812/9315497
    //    return (objc_getAssociatedObject(targetClass, &associatedDynamicTagHandle) as? Bool) ?? false
    
    // This code performance is bad.
    dynamicClassContextPool.contains { (dynamicClassContext) -> Bool in
        dynamicClassContext.dynamicClass == targetClass
    }
}
