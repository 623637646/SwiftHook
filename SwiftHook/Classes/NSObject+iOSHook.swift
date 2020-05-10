//
//  NSObjectExtension.swift
//  SwiftHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation
import libffi_iOS

// TODO: tests
public enum SwiftHookError: Error {
    case noRespondSelector(class: AnyClass, selector: Selector)
    case missingSignature
    case incompatibleClosureSignature
    case ffiError
    case internalError(file: String, line: Int)
}

enum HookMode {
    case before
    case after
    case instead
}

// TODO: Thread synchronization

extension NSObject {
    
    // MARK: Hook single instance
    
    @discardableResult
    public func hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        try parametersCheck(targetClass: type(of: self), selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(object: self, selector: selector, mode: .before, hookClosure: closure)
    }
    
    @discardableResult
    public func hookBefore(selector: Selector, closure: Any) throws -> HookContext {
        try parametersCheck(targetClass: type(of: self), selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(object: self, selector: selector, mode: .before, hookClosure: closure)
    }
        
    @discardableResult
    public func hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        try parametersCheck(targetClass: type(of: self), selector: selector, closure: closure, mode: .after)
        return try HookManager.shared.hook(object: self, selector: selector, mode: .after, hookClosure: closure)
    }
    
    @discardableResult
    public func hookAfter(selector: Selector, closure: Any) throws -> HookContext {
        try parametersCheck(targetClass: type(of: self), selector: selector, closure: closure, mode: .after)
        return try HookManager.shared.hook(object: self, selector: selector, mode: .after, hookClosure: closure)
    }
        
    @discardableResult
    public func hookInstead(selector: Selector, closure: Any) throws -> HookContext {
        try parametersCheck(targetClass: type(of: self), selector: selector, closure: closure, mode: .instead)
        return try HookManager.shared.hook(object: self, selector: selector, mode: .instead, hookClosure: closure)
    }
    
    // MARK: Hook all instances
    
    @discardableResult
    public class func hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        try parametersCheck(targetClass: self, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure)
    }
    
    // TODO: Try to improve API for this
    @discardableResult
    public class func hookBefore(selector: Selector, closure: Any) throws -> HookContext {
        try parametersCheck(targetClass: self, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        try parametersCheck(targetClass: self, selector: selector, closure: closure, mode: .after)
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .after, hookClosure: closure)
    }
    
    @discardableResult
    public class func hookAfter(selector: Selector, closure: Any) throws -> HookContext {
        try parametersCheck(targetClass: self, selector: selector, closure: closure, mode: .after)
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .after, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookInstead(selector: Selector, closure: Any) throws -> HookContext {
        try parametersCheck(targetClass: self, selector: selector, closure: closure, mode: .instead)
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .instead, hookClosure: closure)
    }
    
    // MARK: Hook class methods
    
    @discardableResult
    public class func hookClassMethodBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try parametersCheck(targetClass: metaclass, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure)
    }
    
    @discardableResult
    public class func hookClassMethodBefore(selector: Selector, closure: Any) throws -> HookContext {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try parametersCheck(targetClass: metaclass, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookClassMethodAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try parametersCheck(targetClass: metaclass, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure)
    }
    
    @discardableResult
    public class func hookClassMethodAfter(selector: Selector, closure: Any) throws -> HookContext {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try parametersCheck(targetClass: metaclass, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookClassMethodInstead(selector: Selector, closure: Any) throws -> HookContext {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try parametersCheck(targetClass: metaclass, selector: selector, closure: closure, mode: .before)
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .instead, hookClosure: closure)
    }
}

func parametersCheck(targetClass: AnyClass, selector: Selector, closure: Any, mode: HookMode) throws {
    // TODO: Selector black list.
    guard let method = class_getInstanceMethod(targetClass, selector) else {
        throw SwiftHookError.noRespondSelector(class: targetClass, selector: selector)
    }
    try Signature.canHookClosureWorksByMethod(closure: closure, method: method, mode: mode)
}
