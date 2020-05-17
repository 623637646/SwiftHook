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
    private let dynamicClassHookToken: HookToken
    
    fileprivate init(baseClass: AnyClass) throws {
        self.baseClass = baseClass
        let dynamicClassName = prefix + "\(baseClass)"
        guard let dynamicClass = objc_allocateClassPair(baseClass, dynamicClassName, 0) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        // Hook "Get Class"
        dynamicClassHookToken = try HookManager.shared.hook(targetClass: dynamicClass, selector: NSSelectorFromString("class"), mode: .instead, hookClosure: {_ in
            return baseClass
            } as @convention(block) (() -> AnyClass) -> AnyClass as AnyObject)
        objc_registerClassPair(dynamicClass)
        self.dynamicClass = dynamicClass
    }
    
    deinit {
        // TODO: 这里可能有问题，如果这个对象在HOOK后被KVO，那么会miss掉KVO。
        HookManager.shared.cancelHook(token: dynamicClassHookToken)
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
 Wrap dynamic class to object for single hook. Return new class
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
    NSStringFromClass(targetClass).hasPrefix(prefix)
}
