//
//  HookCommon.swift
//  SwiftHook
//
//  Created by Yanni Wang on 24/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import Foundation

// queue
let swiftHookSerialQueue = DispatchQueue(label: "com.yanni.SwiftHook")

// default selectors
let deallocSelector = NSSelectorFromString("dealloc")

// MARK: - Error
public enum SwiftHookError: Error {
    
    case hookClassWithObjectAPI // Can't hook class with object hooking API. Please use "hookClassMethod" instead.
    
    case blacklist // Unsupport to hook current method. Search "blacklistSelectors" to see all methods unsupport.
    
    case pureSwiftObjectDealloc // Technologically can't hook dealloc method for pure Swift Object with swizzling. Please use "hookDeallocAfterByTail" to hook pure swift object's dealloc method.
    
    case noRespondSelector // Can't find the method by the selector from the class.
    
    case emptyStruct // The struct of the method's args or return value is empty, This case can't be compatible  with libffi. Please check the parameters or return type of the method.
    
    case wrongTypeForHookClosure // Please check the hook clousre. Is it a standard closure? Does it have keyword @convention(block)?
    
    case incompatibleClosureSignature(description: String) // Please check the hook closure if it match to the method.
    
    case duplicateHookClosure // This closure has been hooked with current mode already.
    
    case ffiError // The error from FFI. Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new
    
    case internalError(file: String, line: Int) // Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new
    
    case hookInstanceOfNSTaggedPointerString // Unsupport to hook instance of NSTaggedPointerString.
    
    case hookKVOUnsupportedInstance // Unable to hook a instance which is not support KVO.
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
            _ = try? internalCancelHook(token: self)
        }
    }
}
