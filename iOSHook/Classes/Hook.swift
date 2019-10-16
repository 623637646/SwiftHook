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
func _hook(obj: NSObject) throws -> Token? {
    let theClass = type(of: obj)
    if class_isMetaClass(theClass) {
        // TODO
    } else if NSStringFromClass(theClass).hasPrefix(iOSHookSubclassSuffix) {
        // already subclass
    } else {
        // normal instance
        guard let subclass = try createSubclass(baseClass: theClass) else {
            return nil
        }
        let _ = object_setClass(obj, subclass)
        let _ = object_getClassName(obj)
        let _ = object_getClass(obj)
        print("")
    }
    return Token()
}

func createSubclass(baseClass: NSObject.Type) throws -> NSObject.Type? {
    let className = NSStringFromClass(baseClass)
    let subclassName = "\(className)\(iOSHookSubclassSuffix)"
    var subclass = objc_getClass(subclassName) as? NSObject.Type
    guard subclass == nil else {
        throw iOSHookError(code: .internalError, description: "Existing iOS hook subclass of \(baseClass)")
    }
    subclass = objc_allocateClassPair(baseClass, subclassName, 0) as? NSObject.Type
    guard let subclassNoNil = subclass else {
        throw iOSHookError(code: .internalError, description: "objc_allocateClassPair failed (baseClass: \(baseClass)")
    }
    objc_registerClassPair(subclassNoNil);
    return subclassNoNil
}
