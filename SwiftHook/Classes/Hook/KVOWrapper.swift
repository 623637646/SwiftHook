//
//  KVODynamicClass.swift
//  SwiftHook
//
//  Created by Wang Ya on 12/27/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private var KVOContext = 0

private class Observer: NSObject {
    
    private static let keyPath = "swiftHookPrivateProperty"
        
    private unowned(unsafe) let target: NSObject
    
    init(target: NSObject) {
        self.target = target
        super.init()
        target.addObserver(self, forKeyPath: Observer.keyPath, options: .new, context: &KVOContext)
    }
    
    deinit {
        self.target.removeObserver(self, forKeyPath: Observer.keyPath, context: &KVOContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Observer.keyPath {
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

func wrapKVOIfNeeded(object: NSObject, selector: Selector) throws {
    if !isWrappedKVO(object: object) {
        object.swiftHookObserver = Observer.init(target: object)
    }
    guard let KVOedClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    if getMethodWithoutSearchingSuperClasses(targetClass: KVOedClass, selector: selector) == nil,
       let propertyName = getKVOName(object: object, setter: selector) {
        guard let observer = object.swiftHookObserver else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        object.addObserver(observer, forKeyPath: propertyName, options: .new, context: &KVOContext)
        object.removeObserver(observer, forKeyPath: propertyName, context: &KVOContext)
    }
}

private let setMethodPrefix = "set"
private let setMethodSuffix = ":"
// return nil if the selector is not a setter.
func getKVOName(object: NSObject, setter: Selector) -> String? {
    let setterName = NSStringFromSelector(setter)
    guard setterName.hasPrefix(setMethodPrefix) && setterName.hasSuffix(setMethodSuffix) else {
        return nil
    }
    let propertyNameWithUppercase = String(setterName.dropFirst(setMethodPrefix.count).dropLast(setMethodSuffix.count))
    return propertyNameWithUppercase
//    guard let firstCharacter = propertyNameWithUppercase.first else {
//        return nil
//    }
//    let firstCharacterLowercase = firstCharacter.lowercased()
//    let propertyName = firstCharacterLowercase + propertyNameWithUppercase.dropFirst()
//    guard let baseClass = object_getClass(object) else {
//        throw SwiftHookError.internalError(file: #file, line: #line)
//    }
//    if let property = class_getProperty(baseClass, propertyName) {
//        // If setter is "setNumber:". This will return "number"
//        return String.init(cString: property_getName(property))
//    }
//    if let property = class_getProperty(baseClass, propertyNameWithUppercase) {
//        // If setter is "setNumber:". This will return "Number"
//        return String.init(cString: property_getName(property))
//    }
//    if object.responds(to: NSSelectorFromString(propertyName)) {
//        // If setter is "setNumber:". This will return "number"
//        return propertyName
//    }
//    if object.responds(to: NSSelectorFromString(propertyNameWithUppercase)) {
//        // If setter is "setNumber:". This will return "number"
//        return propertyNameWithUppercase
//    }
//    if object.responds(to: NSSelectorFromString("is" + propertyNameWithUppercase)) {
//        return propertyName
//    }
//    return nil
}

func unwrapKVOIfNeeded(object: NSObject) {
    guard isWrappedKVO(object: object) else {
        return
    }
    object.swiftHookObserver = nil
}

func isWrappedKVO(object: NSObject) -> Bool {
    return object.swiftHookObserver != nil
}

// MARK: extension

private extension NSObject {
    static var swiftHookObserverAssociatedKey = 0
    var swiftHookObserver: Observer? {
        get {
            return objc_getAssociatedObject(self, &NSObject.swiftHookObserverAssociatedKey) as? Observer
        }
        set {
            objc_setAssociatedObject(self, &NSObject.swiftHookObserverAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
