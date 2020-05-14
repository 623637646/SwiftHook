//
//  DynamicClass.swift
//  SwiftHook
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private let prefix = "SwiftHook_"
private var associatedDynamicClassContextHandle: UInt8 = 0

private class DynamicClassContext {
    fileprivate let dynamicClass: AnyClass
    private let originalClass: AnyClass
    private weak var object: AnyObject?
    private let dynamicClassHookToken: HookToken
    
    fileprivate init(object: AnyObject) throws {
        self.object = object
        guard let baseClass = object_getClass(object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.originalClass = baseClass
        let address = Unmanaged.passUnretained(object).toOpaque()
        let dynamicClassName = prefix + "\(baseClass)" + "_\(address)"
        guard let dynamicClass = objc_allocateClassPair(baseClass, dynamicClassName, 0) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        // Hook "Get Class"
        dynamicClassHookToken = try HookManager.shared.hook(targetClass: dynamicClass, selector: NSSelectorFromString("class"), mode: .instead, hookClosure: {_ in
            return baseClass
            } as @convention(block) (() -> AnyClass) -> AnyClass as AnyObject)
        objc_registerClassPair(dynamicClass)
        object_setClass(object, dynamicClass)
        self.dynamicClass = dynamicClass
    }
    
    deinit {
        // TODO: 这里可能有问题，如果这个对象在HOOK后被KVO，那么会miss掉KVO。
        object_setClass(self.object, originalClass)
        dynamicClassHookToken.cancelHook()
        objc_disposeClassPair(dynamicClass)
    }
}

/**
 Wrap dynamic class to object for single hook. Return new class
 */
func wrapDynamicClass(object: AnyObject, hookClosure: AnyObject) throws -> AnyClass {
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard !NSStringFromClass(baseClass).hasPrefix(prefix) else {
        guard let dynamicClassContext: DynamicClassContext = objc_getAssociatedObject(object, &associatedDynamicClassContextHandle) as? DynamicClassContext else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        objc_setAssociatedObject(hookClosure, &associatedDynamicClassContextHandle, dynamicClassContext, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return dynamicClassContext.dynamicClass
    }
    let dynamicClassContext = try DynamicClassContext.init(object: object)
    objc_setAssociatedObject(hookClosure, &associatedDynamicClassContextHandle, dynamicClassContext, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    // Here do objc_setAssociatedObject with OBJC_ASSOCIATION_ASSIGN. But no crash when objc_getAssociatedObject. Because after DynamicClassContext released. The object's class will be reset to original class.
    objc_setAssociatedObject(object, &associatedDynamicClassContextHandle, dynamicClassContext, .OBJC_ASSOCIATION_ASSIGN)
    return dynamicClassContext.dynamicClass
}
