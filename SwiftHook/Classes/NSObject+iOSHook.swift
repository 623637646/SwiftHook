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

extension NSObject {
    
    // MARK: Before
    
    @discardableResult
    public class func hookBefore(selector: Selector, closure: @convention(block) () -> Void) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, closure: closure as AnyObject, mode: .before)
        if getMethodWithoutSearchingSuperClasses(targetClass: self, selector: selector) == nil {
            //  TODO: add method
        }
        return try HookContext.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
    
    // TODO: Try to improve API for this
    @discardableResult
    public class func hookBefore(selector: Selector, closure: AnyObject) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, closure: closure as AnyObject, mode: .before)
        if getMethodWithoutSearchingSuperClasses(targetClass: self, selector: selector) == nil {
            //  TODO: add method
        }
        return try HookContext.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
    
    // MARK: After
    
    @discardableResult
    public class func hookAfter(selector: Selector, closure: @convention(block) () -> Void) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, closure: closure as AnyObject, mode: .after)
        if getMethodWithoutSearchingSuperClasses(targetClass: self, selector: selector) == nil {
            //  TODO: add method
        }
        return try HookContext.hook(targetClass: self, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
    
    @discardableResult
    public class func hookAfter(selector: Selector, closure: AnyObject) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, closure: closure as AnyObject, mode: .after)
        if getMethodWithoutSearchingSuperClasses(targetClass: self, selector: selector) == nil {
            //  TODO: add method
        }
        return try HookContext.hook(targetClass: self, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
    
    // MARK: Instead
    
    @discardableResult
    public class func hookInstead(selector: Selector, closure: AnyObject) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, closure: closure as AnyObject, mode: .instead)
        if getMethodWithoutSearchingSuperClasses(targetClass: self, selector: selector) == nil {
            //  TODO: add method
        }
        return try HookContext.hook(targetClass: self, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
    
    // MARK: private
    
    private class func parametersCheck(selector: Selector, closure: AnyObject, mode: HookMode) throws {
        // TODO: Selector black list.
        guard let method = class_getInstanceMethod(self, selector) else {
            throw SwiftHookError.noRespondSelector(class: self, selector: selector)
        }
        guard let methodSignature = Signature(method: method),
            let closureSignature = Signature(closure: closure) else {
                throw SwiftHookError.missingSignature
        }
        guard let emptyClosure = Signature(closure: {} as @convention(block) () -> Void as AnyObject) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        switch mode {
        case .before:
            if methodSignature.isMatch(other: closureSignature) ||
                closureSignature.isMatch(other: emptyClosure) {
                return
            }
        case .after:
            if methodSignature.isMatch(other: closureSignature) ||
                closureSignature.isMatch(other: emptyClosure) {
                return
            }
        case .instead:
            if methodSignature.argumentTypes.count + 1 == closureSignature.argumentTypes.count {
                for (index, argumentType) in closureSignature.argumentTypes.enumerated() {
                    if index == 0 {
                        // TODO:
                        guard argumentType == "@" else {
                            throw SwiftHookError.incompatibleClosureSignature
                        }
                    } else {
                        guard argumentType == methodSignature.argumentTypes[index - 1] else {
                            throw SwiftHookError.incompatibleClosureSignature
                        }
                    }
                }
                return
            }
        }
        throw SwiftHookError.incompatibleClosureSignature
    }
}
