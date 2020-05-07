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
    
    @discardableResult
    public class func hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, closure: closure as AnyObject, mode: .before)
        if getMethodWithoutSearchingSuperClasses(targetClass: self, selector: selector) == nil {
            //  TODO: add method
        }
        return try HookContext.hook(targetClass: self, selector: selector, mode: .before, hookClosure: closure as AnyObject)
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
        guard !methodSignature.isMatch(other: closureSignature) else {
            return
        }
        guard let emptyClosure = Signature(closure: {} as @convention(block) () -> Void as AnyObject) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        switch mode {
        case .before:
            if closureSignature.isMatch(other: emptyClosure) {
                return
            }
        case .after:
            if closureSignature.isMatch(other: emptyClosure) {
                return
            }
        case .instead: break
        }
        throw SwiftHookError.incompatibleClosureSignature
    }
}
