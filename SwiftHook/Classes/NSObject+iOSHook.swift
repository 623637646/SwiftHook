//
//  NSObjectExtension.swift
//  SwiftHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation
import libffi_iOS

public enum SwiftHookError: Error {
    case noRespondSelector(class: AnyClass, selector: Selector)
    case missingSignature
    case incompatibleBlockSignature
    case ffiError
    case unknow
}

enum HookMode {
    case before
    case after
    case instead
}

extension NSObject {
    
    @discardableResult
    public class func hookBefore(selector: Selector, block: @escaping @convention(block) () -> Void) throws -> HookContext {
        // TODO: Thread synchronization
        try self.parametersCheck(selector: selector, block: block as Any, mode: .before)
        if !isSelfMethod(selector: selector) {
            //  TODO: add method
        }
        return try HookContext.hook(class: self, selector: selector, mode: .before, hookBlock: block as AnyObject)
    }
    
    // MARK: private
    
    private class func isSelfMethod(selector: Selector) -> Bool {
        var length: UInt32 = 0
        let firstMethod = class_copyMethodList(self, UnsafeMutablePointer(&length))
        let bufferPointer = UnsafeBufferPointer.init(start: firstMethod, count: Int(length))
        for method in bufferPointer {
            if method_getName(method) == selector {
                return true
            }
        }
        return false
    }
    
    private class func parametersCheck(selector: Selector, block: Any, mode: HookMode) throws {
        // TODO: Selector black list.
        guard self.instancesRespond(to: selector) else {
            throw SwiftHookError.noRespondSelector(class: self, selector: selector)
        }
        guard let methodSignature = Signature(class: self, selector: selector),
            let closureSignature = Signature(closure: block) else {
                throw SwiftHookError.missingSignature
        }
        guard !methodSignature.isMatch(other: closureSignature) else {
            return
        }
        guard let emptyClosure = Signature(closure: {} as @convention(block) () -> Void) else {
            throw SwiftHookError.unknow
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
        throw SwiftHookError.incompatibleBlockSignature
    }
}
