//
//  Hook.swift
//  iOSHook
//
//  Created by Yanni Wang on 15/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

let iOSHookSubclassSuffix = "_iOSHook_";

// TODO: Probably a KVO'ed class. Swizzle in place. Also swizzle meta classes in place???
func hook(instance: InstanceHookContainer) throws -> Token? {
    guard let obj = instance.obj else {
        throw iOSHookError(code: .internalError, description: "obj is released")
    }
    guard let theClass: AnyClass = object_getClass(obj) else {
        throw iOSHookError(code: .internalError, description: "object_getClass of \(obj) is nil")
    }
    guard !class_isMetaClass(theClass) else {
        throw iOSHookError(code: .internalError, description: "class_isMetaClass of \(obj)'s class \(theClass) is true")
    }
    if !NSStringFromClass(theClass).hasPrefix(iOSHookSubclassSuffix) {
        // not create subclass yet
        let subclass: AnyClass = try createSubclass(baseClass: theClass)
        object_setClass(obj, subclass);
    }
    return Token()
}

func createSubclass(baseClass: AnyClass) throws -> AnyClass {
    let className = NSStringFromClass(baseClass)
    let subclassName = "\(className)\(iOSHookSubclassSuffix)"
    guard NSClassFromString(subclassName) == nil else {
        throw iOSHookError(code: .internalError, description: "Existing iOS hook subclass of \(baseClass)")
    }
    guard let subclass: AnyClass = objc_allocateClassPair(baseClass, subclassName, 0) else {
        throw iOSHookError(code: .internalError, description: "objc_allocateClassPair failed with name \(subclassName) base on \(baseClass)")
    }
    objc_registerClassPair(subclass);
    return subclass
}
