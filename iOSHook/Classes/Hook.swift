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
func _hook(obj: NSObject, error: inout Error?) -> Token? {
    let theClass = type(of: obj)
    if class_isMetaClass(theClass) {
        // TODO
    } else if NSStringFromClass(theClass).hasPrefix(iOSHookSubclassSuffix) {
        // already subclass
    } else {
        // normal instance
        guard let subclass = createSubclass(baseClass: theClass, error: &error) else {
            return nil
        }
        let a = object_setClass(obj, subclass)
        let b = object_getClassName(obj)
        let c = object_getClass(obj)
        print("")
    }
    return Token()
}

func createSubclass(baseClass: NSObject.Type, error: inout Error?) -> NSObject.Type? {
    let className = NSStringFromClass(baseClass)
    let subclassName = "\(className)\(iOSHookSubclassSuffix)"
    var subclass = objc_getClass(subclassName) as? NSObject.Type
    guard subclass == nil else {
        assert(false)
        error? = getError(code: .internalError, description: "Existing iOS hook subclass of \(baseClass)")
        return nil
    }
    subclass = objc_allocateClassPair(baseClass, subclassName, 0) as? NSObject.Type;
    guard let subclassNoNil = subclass else {
        error? = getError(code: .internalError, description: "objc_allocateClassPair failed (baseClass: \(baseClass)")
        return nil
    }
    objc_registerClassPair(subclassNoNil);
    return subclassNoNil
}
