//
//  DynamicClassContext.swift
//  SwiftHook
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private let prefix = "SwiftHook_"
private var associatedDynamicClassContextHandle: UInt8 = 0

class DynamicClassContext {
    let dynamicClass: AnyClass
    let originalClass: AnyClass
    weak var object: AnyObject?
    
    private init(object: AnyObject) throws {
        self.object = object
        guard let baseClass = object_getClass(object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        self.originalClass = baseClass
        let address = Unmanaged.passUnretained(object).toOpaque().hashValue
        let dynamicClassName = prefix + NSStringFromClass(baseClass) + "_\(address)"
        guard let dynamicClass = objc_allocateClassPair(baseClass, dynamicClassName, 0) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        objc_registerClassPair(dynamicClass)
        self.dynamicClass = dynamicClass
        object_setClass(object, dynamicClass)
    }
    
    deinit {
        object_setClass(self.object, originalClass)
        objc_disposeClassPair(dynamicClass)
    }
    
    private class func isDynamicClass(object: AnyObject) -> Bool {
        guard let baseClass = object_getClass(object) else {
            return false
        }
        return NSStringFromClass(baseClass).hasPrefix(prefix)
    }
    
    class func getDynamicClass(object: AnyObject) throws -> AnyClass {
        guard !isDynamicClass(object: object) else {
            guard let dynamicClassContext: DynamicClassContext = objc_getAssociatedObject(object, &associatedDynamicClassContextHandle) as? DynamicClassContext else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            return dynamicClassContext.dynamicClass
        }
        let dynamicClassContext = try DynamicClassContext.init(object: object)
        objc_setAssociatedObject(object, &associatedDynamicClassContextHandle, dynamicClassContext, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return dynamicClassContext.dynamicClass
    }
    
}
