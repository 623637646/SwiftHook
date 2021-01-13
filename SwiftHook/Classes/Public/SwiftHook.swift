//
//  SwiftHook.swift
//  SwiftHook
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

// MARK: - Constant

// queue
private let swiftHookSerialQueue = DispatchQueue(label: "com.yanni.SwiftHook")

// default selectors
let deallocSelector = NSSelectorFromString("dealloc")

// MARK: - Error
public enum SwiftHookError: Error {
    
    case hookClassWithObjectAPI // Can't hook class with object hooking API. Please use "hookClassMethod" instead.
    
    case blacklist // Unsupport to hook current method. Search "blacklistSelectors" to see all methods unsupport.

    case pureSwiftObjectDealloc // Technologically can't hook dealloc method for pure Swift Object with swizzling. Please use "hookDeallocAfterByTail" to hook pure swift object's dealloc method.

    /*
     // TODO: Support hook KVO'ed Object.
     
     Cases:
     1. Observe one object by KVO.
     2. Hook this object by SwiftHook
     3. Cancel KVO
     4. Make sure SwiftHook works fine.
     
     Latest idea. Set the object a new subclass. The subclass copy superclass's extra-bytes to avoid KVO crash.
     */
    case KVOedObject // Unsupport to hook KVO'ed Object

    case noRespondSelector // Can't find the method by the selector from the class.

    case emptyStruct // The struct of the method's args or return value is empty, This case can't be compatible  with libffi. Please check the parameters or return type of the method.

    case wrongTypeForHookClosure // Please check the hook clousre. Is it a standard closure? Does it have keyword @convention(block)?

    case incompatibleClosureSignature(description: String) // Please check the hook closure if it match to the method.

    case duplicateHookClosure // This closure has been hooked with current mode already.

    case ffiError // The error from FFI. Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new
    
    case internalError(file: String, line: Int) // Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new
}

// MARK: - Token
public protocol Token {
    func cancelHook()
}

struct HookToken: Token {
    
    weak var hookContext: HookContext?
    weak var hookClosure: AnyObject?
    let mode: HookMode
    
    weak var hookObject: AnyObject? // This is only for specified instance hook
    
    init(hookContext: HookContext, hookClosure: AnyObject, mode: HookMode) {
        self.hookContext = hookContext
        self.hookClosure = hookClosure
        self.mode = mode
    }
    
    func cancelHook() {
        swiftHookSerialQueue.sync {
            _ = internalCancelHook(token: self)
        }
    }
}

// MARK: - Hook specified instance

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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(object: object, selector: selector, mode: .before, closure: closure as AnyObject)
        return try internalHook(object: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)
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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(object: object, selector: selector, mode: .after, closure: closure as AnyObject)
        return try internalHook(object: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
 Totally override the mehtod for specified instance. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
 */
@discardableResult
public func hookInstead(object: AnyObject, selector: Selector, closure: Any) throws -> Token {
    return try swiftHookSerialQueue.sync {
        try parametersCheck(object: object, selector: selector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(object: object, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: - Hook all instances

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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
Totally override the mehtod for all instances of the class. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
*/
@discardableResult
public func hookInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    return try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: targetClass, selector: selector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: - Hook class methods

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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: metaclass, selector: selector, mode: .before, closure: closure as AnyObject)
        return try internalHook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: metaclass, selector: selector, mode: .after, closure: closure as AnyObject)
        return try internalHook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
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
    return try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: metaclass, selector: selector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(targetClass: metaclass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: - Hook specified instance dealloc

/**
 Perform the hook closure before executing the instance dealloc method. This API only works for NSObject.
 */
@discardableResult
public func hookDeallocBefore(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try parametersCheck(object: object, selector: deallocSelector, mode: .before, closure: closure as AnyObject)
        return try internalHook(object: object, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
Perform the hook closure after executing the instance dealloc method. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocAfter(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try parametersCheck(object: object, selector: deallocSelector, mode: .after, closure: closure as AnyObject)
        return try internalHook(object: object, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
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
        try parametersCheck(object: object, selector: deallocSelector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(object: object, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: - Hook all instances dealloc

/**
Perform the hook closure before executing the dealloc method of all instances of the class. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocBefore(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .before, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
Perform the hook closure after executing the dealloc method of all instances of the class. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocAfter(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .after, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

/**
Totally override the dealloc mehtod for all instances of the class. Have to call original to avoid memory leak. This API only works for NSObject.
*/
@discardableResult
public func hookDeallocInstead(targetClass: NSObject.Type, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> Token {
    try swiftHookSerialQueue.sync {
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}
