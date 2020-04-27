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
    case canNotFindMethod(class:AnyClass, selector: Selector)
}

public extension NSObject {
    
    class func hookBefore(selector: Selector, block: () -> ()) {
        guard let method = class_getInstanceMethod(self, selector) else {
            assert(false)
        }
        
    }
}
