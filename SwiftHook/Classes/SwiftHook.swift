//
//  SwiftHook.swift
//  SwiftHook
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

public enum SwiftHookError: Error {
    
    public enum UnsupportType {
        case insteadHookNSObjectDealloc
        case hookSwiftObjectDealloc
    }
    
    case noRespondSelector(targetClass: AnyClass, selector: Selector)
    case missingSignature // Please check if there is keyword @convention(block) for the clousre
    case incompatibleClosureSignature
    case unsupport(type: UnsupportType)
    case canNotHookClassWithObjectAPI
    case ffiError
    case internalError(file: String, line: Int)
}

let swiftHookSerialQueue = DispatchQueue(label: "com.yanni.SwiftHook")
let deallocSelector = NSSelectorFromString("dealloc")
private var associatedDelegateHandle: UInt8 = 0

// MARK: Hook single instance

@discardableResult
public func hookBefore(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookBefore(object: AnyObject, selector: Selector, closure: Any) throws -> HookToken {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    return try swiftHookSerialQueue.sync {
        return try HookManager.shared.hook(object: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(object: AnyObject, selector: Selector, closure: Any) throws -> HookToken {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookInstead(object: AnyObject, selector: Selector, closure: Any) throws -> HookToken {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook all instances

@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> HookToken {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> HookToken {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> HookToken {
    try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook class methods

@discardableResult
public func hookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> HookToken {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> HookToken {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookClassMethodInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> HookToken {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook dealloc

// NSObject

@discardableResult
public func hookDeallocBefore(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(object: object, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookDeallocAfter(object: AnyObject, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    if object is NSObject {
        return try swiftHookSerialQueue.sync {
            try HookManager.shared.hook(object: object, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
        }
    } else {
        let delegate = NSObject()
        objc_setAssociatedObject(object, &associatedDelegateHandle, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return try swiftHookSerialQueue.sync {
            try HookManager.shared.hook(object: delegate, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
        }
    }
}

@discardableResult
public func hookDeallocBefore(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

@discardableResult
public func hookDeallocAfter(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
    return try swiftHookSerialQueue.sync {
        try HookManager.shared.hook(targetClass: targetClass, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

// SwfitObject
