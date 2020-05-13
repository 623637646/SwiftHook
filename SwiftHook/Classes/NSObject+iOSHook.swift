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
    public func hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(object: self, selector: selector, mode: .before, hookClosure: closure)
    }
    
    @discardableResult
    public func hookBefore(selector: Selector, closure: Any) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(object: self, selector: selector, mode: .before, hookClosure: closure)
    }
        
    @discardableResult
    public func hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(object: self, selector: selector, mode: .after, hookClosure: closure)
    }
    
    @discardableResult
    public func hookAfter(selector: Selector, closure: Any) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(object: self, selector: selector, mode: .after, hookClosure: closure)
    }
        
    @discardableResult
    public func hookInstead(selector: Selector, closure: Any) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(object: self, selector: selector, mode: .instead, hookClosure: closure)
    }
    
    // MARK: Hook all instances
    
    @discardableResult
    public class func hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure)
    }
    
    // TODO: Try to improve API for this
    @discardableResult
    public class func hookBefore(selector: Selector, closure: Any) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .after, hookClosure: closure)
    }
    
    @discardableResult
    public class func hookAfter(selector: Selector, closure: Any) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .after, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookInstead(selector: Selector, closure: Any) throws -> HookToken {
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: self, selector: selector, mode: .instead, hookClosure: closure)
    }
    
    // MARK: Hook class methods
    
    @discardableResult
    public class func hookClassMethodBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure)
    }
    
    @discardableResult
    public class func hookClassMethodBefore(selector: Selector, closure: Any) throws -> HookToken {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .before, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookClassMethodAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure)
    }
    
    @discardableResult
    public class func hookClassMethodAfter(selector: Selector, closure: Any) throws -> HookToken {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .after, hookClosure: closure)
    }
        
    @discardableResult
    public class func hookClassMethodInstead(selector: Selector, closure: Any) throws -> HookToken {
        guard let metaclass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let closure = closure as AnyObject
        return try HookManager.shared.hook(targetClass: metaclass, selector: selector, mode: .instead, hookClosure: closure)
    }
}

// TODO: 性能优化，只在入口校验参数.
