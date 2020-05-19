//
//  SwiftHook.swift
//  SwiftHook
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

public enum SwiftHookError: Error {
    
    public enum UnsupportType {
        case hookSwiftObjectDealloc
    }
    
    case noRespondSelector(targetClass: AnyClass, selector: Selector)
    case missingSignature // Please check if there is keyword @convention(block) for the clousre
    case incompatibleClosureSignature
    case unsupport(type: UnsupportType)
    case canNotHookClassWithObjectAPI // Please use "hookClassMethod*" instead.
    case ffiError
    case internalError(file: String, line: Int)
}

let swiftHookSerialQueue = DispatchQueue(label: "com.yanni.SwiftHook")
let deallocSelector = NSSelectorFromString("dealloc")

// MARK: Hook single instance

@discardableResult
public func hookBefore(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookBefore(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookInstead(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: .instead, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook all instances

@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .instead, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook class methods

@discardableResult
public func hookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .instead, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook dealloc

@discardableResult
public func hookDeallocBefore(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookDeallocAfter(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
 This method can hook dealloc in after WITHOUT runtime. Just add a object (tail) to observe dealloc.
 */
@discardableResult
public func hookDeallocTail(object: AnyObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    swiftHookSerialQueue.sync {
        return hookDeallocAfterByDelegate(object: object, closure: closure as AnyObject)
    }
}

/**
 Have to call original to avoid memory leak.
 eg:
 try hookDeallocInstead(object: object, closure: { original in
 original()
 } as @convention(block) (() -> Void) -> Void)
 */
@discardableResult
public func hookDeallocInstead(object: NSObject, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookDeallocBefore(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookDeallocAfter(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
 Have to call original to avoid memory leak.
 eg:
 try hookDeallocInstead(targetClass: targetClass, closure: { original in
 original()
 } as @convention(block) (() -> Void) -> Void)
 */
@discardableResult
public func hookDeallocInstead(targetClass: NSObject.Type, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

private func parametersCheck(targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    // TODO: Selector black list.
    if selector == deallocSelector {
        guard targetClass is NSObject.Type else {
            throw SwiftHookError.unsupport(type: .hookSwiftObjectDealloc)
        }
    }
    
    guard let method = class_getInstanceMethod(targetClass, selector) else {
        throw SwiftHookError.noRespondSelector(targetClass: targetClass, selector: selector)
    }
    try Signature.canHookClosureWorksByMethod(closure: closure, method: method, mode: mode)
}
