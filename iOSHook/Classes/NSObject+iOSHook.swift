//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

public enum iOSHookError: Error {
    case invalidSelector
}

public extension NSObject {
    @discardableResult
    class func hook(selector: Selector,
                    block: (_ original: (_ args: [Any?]) -> Any?, _ args: [Any?]) -> Any?) throws -> Token? {
        var token: Token? = nil
        try DispatchQueue(label: "com.iOSHook.sync").sync {
            guard let method = class_getInstanceMethod(self, selector) else {
                throw iOSHookError.invalidSelector
            }
            
            let originalIMP = method_getImplementation(method)
            let newIMPBlock: @convention(block) (AnyObject) -> Void = {`self` in
                typealias MyCFunction = @convention(c) (AnyObject, Selector) -> Void
                let curriedImplementation = unsafeBitCast(originalIMP, to: MyCFunction.self)
                curriedImplementation(self, selector)
            }

            let newIMP = imp_implementationWithBlock(newIMPBlock)
            let methodType = method_getTypeEncoding(method);
            
            let addedNewMethod = class_replaceMethod(self, selector, newIMP, methodType) == nil
            

            
            token = Token()
        }
        return token
    }
}
