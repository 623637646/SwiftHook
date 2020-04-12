//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

public enum iOSHookError: Error {
    case canNotFindMethod(class:AnyClass, selector: Selector)
}

public extension NSObject {
    @discardableResult
    class func hook<Return, Args>(selector: Selector,
                    block: (_ original: (_ args: Args) -> Return, _ args: Args) -> Return) throws -> Token? {
        var token: Token? = nil
        try DispatchQueue(label: "com.iOSHook.sync").sync {
            guard let method = class_getInstanceMethod(self, selector) else {
                throw iOSHookError.canNotFindMethod(class: self, selector: selector)
            }
            
            let originalIMP = method_getImplementation(method)
            let newIMPBlock: @convention(block) (Self, Int, Double, String) -> Void = {`self`, i, d, s in
                typealias MyCFunction = @convention(c) (AnyObject, Selector, Int, Double, String) -> Void
                let curriedImplementation = unsafeBitCast(originalIMP, to: MyCFunction.self)
                curriedImplementation(self, selector, i, d, s)
            }

            let newIMP = imp_implementationWithBlock(newIMPBlock)
            let methodType = method_getTypeEncoding(method);
            
            let addedNewMethod = class_replaceMethod(self, selector, newIMP, methodType) == nil
            

            
            token = Token()
        }
        return token
    }
}
