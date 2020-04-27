//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation
import libffi

public enum iOSHookError: Error {
    case instancesDoNotRespondSelector(class: AnyClass, selector: Selector)
    case ffiError
    case unknow
}

public extension NSObject {
    
    @discardableResult
    class func hookBefore(selector: Selector, block: @convention(block) () -> ()) throws -> HookToken? {
        // TODO: Thread synchronization
        // TODO: Method signature and block signature checking
        // TODO: Selector black list.
        guard self.instancesRespond(to: selector) else {
            throw iOSHookError.instancesDoNotRespondSelector(class: self, selector: selector)
        }
        if !isSelfMethod(selector: selector) {
            //  TODO: add method
        }
        return try HookToken.hook(class: self, selector: selector, mode: .before, hookBlock: block as AnyObject)
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
}
