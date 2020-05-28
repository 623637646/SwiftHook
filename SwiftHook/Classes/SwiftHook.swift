//
//  SwiftHook.swift
//  SwiftHook
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

public enum SwiftHookError: Error {
    
    public enum Unsupport {
        case pureSwiftObjectDealloc // Please use "hookDeallocAfterByTail" to hook pure swift object's dealloc method
        case KVOedObject // Unsupport to hook KVO'ed Object
        case specifiedInstanceRetain // Unsupport to hook "retian" for specified instance (Can hook this mehtod for all instances).
        case specifiedInstanceRelease // Unsupport to hook "release" for specified instance (Can hook this mehtod for all instances).
    }
    
    case unsupport(value: Unsupport)
    case noRespondSelector
    case missingSignature // Please check if there is keyword @convention(block) for the clousre
    case incompatibleClosureSignature
    case canNotHookClassWithObjectAPI // Please use "hookClassMethod" instead.
    case duplicateHookClosure // This closure already hooked with one mode.
    case ffiError
    case internalError(file: String, line: Int)
}

let swiftHookSerialQueue = DispatchQueue(label: "com.yanni.SwiftHook")
let deallocSelector = NSSelectorFromString("dealloc")
private let KVOPrefix = "NSKVONotifying_"

// MARK: Hook specified instance

/**
 Perform the hook closure before executing specified instance's method.
 */
@discardableResult
public func hookBefore(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try hookBefore(object: object, selector: selector, closure: closure as Any)
}

/**
 Perform the hook closure before executing specified instance's method.
 */
@discardableResult
public func hookBefore(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(object: object, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(object: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
 Perform the hook closure after executing specified instance's method.
 */
@discardableResult
public func hookAfter(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try hookAfter(object: object, selector: selector, closure: closure as Any)
}

/**
 Perform the hook closure after executing specified instance's method.
 */
@discardableResult
public func hookAfter(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(object: object, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(object: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
 Totally override the mehtod for specified instance. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
 */
@discardableResult
public func hookInstead(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(object: object, selector: selector, mode: .instead, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(object: object, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook all instances

/**
 Perform the hook closure before executing the method of all instances of the class.
 */
@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try hookBefore(targetClass: targetClass, selector: selector, closure: closure as Any)
}

/**
Perform the hook closure before executing the method of all instances of the class.
*/
@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
Perform the hook closure after executing the method of all instances of the class.
*/
@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try hookAfter(targetClass: targetClass, selector: selector, closure: closure as Any)
}

/**
Perform the hook closure after executing the method of all instances of the class.
*/
@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
Totally override the mehtod for all instances of the class. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
*/
@discardableResult
public func hookInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    try parametersCheck(targetClass: targetClass, selector: selector, mode: .instead, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook class methods

/**
Perform the hook closure before executing the class method.
*/
@discardableResult
public func hookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try hookClassMethodBefore(targetClass: targetClass, selector: selector, closure: closure as Any)
}

/**
Perform the hook closure before executing the class method.
*/
@discardableResult
public func hookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .before, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
Perform the hook closure after executing the class method.
*/
@discardableResult
public func hookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try hookClassMethodAfter(targetClass: targetClass, selector: selector, closure: closure as Any)
}

/**
Perform the hook closure after executing the class method.
*/
@discardableResult
public func hookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .after, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
Totally override the class mehtod. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
*/
@discardableResult
public func hookClassMethodInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    guard let metaclass = object_getClass(targetClass) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: metaclass, selector: selector, mode: .instead, closure: closure as AnyObject)
    return try swiftHookSerialQueue.sync {
        try internalHook(targetClass: metaclass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook specified instance dealloc

/**
 Perform the hook closure before executing the instance dealloc method. This API only works for NSObject.
 */
@discardableResult
public func hookDeallocBefore(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try internalHook(object: object, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
Perform the hook closure after executing the instance dealloc method. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocAfter(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try internalHook(object: object, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
Perform hook closure after executing the instance dealloc method. This isn't using runtime. Just add a "Tail" to the instance. The instance is the only object retaining "Tail" object. So when the instance releasing. "Tail" know this event. This API can work for NSObject and pure Swift object.
*/
@discardableResult
public func hookDeallocAfterByTail(object: AnyObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    swiftHookSerialQueue.sync {
        return hookDeallocAfterByDelegate(object: object, closure: closure as AnyObject)
    }
}

/**
 Totally override the dealloc mehtod for specified instance. Have to call original to avoid memory leak. This API only works for NSObject.
 */
@discardableResult
public func hookDeallocInstead(object: NSObject, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try internalHook(object: object, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: Hook all instances dealloc

/**
Perform the hook closure before executing the dealloc method of all instances of the class. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocBefore(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
Perform the hook closure after executing the dealloc method of all instances of the class. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocAfter(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
Totally override the dealloc mehtod for all instances of the class. Have to call original to avoid memory leak. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocInstead(targetClass: NSObject.Type, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: private

private func parametersCheck(object: AnyObject, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard selector != NSSelectorFromString("retain") else {
        throw SwiftHookError.unsupport(value: .specifiedInstanceRetain)
    }
    guard selector != NSSelectorFromString("release") else {
        throw SwiftHookError.unsupport(value: .specifiedInstanceRelease)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: mode, closure: closure)
}

private func parametersCheck(targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    if selector == deallocSelector {
        guard targetClass is NSObject.Type else {
            throw SwiftHookError.unsupport(value: .pureSwiftObjectDealloc)
        }
    }
    guard !NSStringFromClass(targetClass).hasPrefix(KVOPrefix) else {
        throw SwiftHookError.unsupport(value: .KVOedObject)
    }
    guard let method = class_getInstanceMethod(targetClass, selector) else {
        throw SwiftHookError.noRespondSelector
    }
    
    guard let methodSignature = Signature(method: method),
        let closureSignature = Signature(closure: closure) else {
            throw SwiftHookError.missingSignature
    }
    try Signature.canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: mode)
}
