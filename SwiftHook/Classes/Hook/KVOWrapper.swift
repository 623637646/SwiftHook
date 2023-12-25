//
//  KVODynamicClass.swift
//  SwiftHook
//
//  Created by Wang Ya on 12/27/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import SwiftHookOCSources
#endif

private var swiftHookKVOContext = 0
private let swiftHookKeyPath = "swiftHookPrivateProperty"

private class RealObserver: NSObject {
    
    static let shared = RealObserver()
    
    private override init() {
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == swiftHookKeyPath {
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

private class Observer: NSObject {
    
    private unowned(unsafe) let target: NSObject
    
    init(target: NSObject) {
        self.target = target
        super.init()
        target.addObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, options: .new, context: &swiftHookKVOContext)
    }
    
    deinit {
        self.target.removeObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, context: &swiftHookKVOContext)
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
       let propertyName = try getKVOName(object: object, setter: selector) {
        guard let observer = object.swiftHookObserver else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        // With this code. `getMethodWithoutSearchingSuperClasses(targetClass: KVOedClass, selector: selector)` will be non-nil.
        object.addObserver(observer, forKeyPath: propertyName, options: .new, context: &swiftHookKVOContext)
        object.removeObserver(observer, forKeyPath: propertyName, context: &swiftHookKVOContext)
    }
}

private let setMethodPrefix = "set"
private let setMethodSuffix = ":"
// return nil if the selector is not a setter.
func getKVOName(object: NSObject, setter: Selector) throws -> String? {
    let setterName = NSStringFromSelector(setter)
    guard setterName.hasPrefix(setMethodPrefix) && setterName.hasSuffix(setMethodSuffix) else {
        return nil
    }
    let propertyNameWithUppercase = String(setterName.dropFirst(setMethodPrefix.count).dropLast(setMethodSuffix.count))
    guard let firstCharacter = propertyNameWithUppercase.first else {
        return nil
    }
    let firstCharacterLowercase = firstCharacter.lowercased()
    let propertyName = firstCharacterLowercase + propertyNameWithUppercase.dropFirst()
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    if let property = class_getProperty(baseClass, propertyName) {
        // If setter is "setNumber:". This will return "number"
        return String.init(cString: property_getName(property))
    }
    if let property = class_getProperty(baseClass, propertyNameWithUppercase) {
        // If setter is "setNumber:". This will return "Number"
        return String.init(cString: property_getName(property))
    }
    if object.responds(to: NSSelectorFromString(propertyName)) {
        // If setter is "setNumber:". This will return "number"
        return propertyName
    }
    if object.responds(to: NSSelectorFromString(propertyNameWithUppercase)) {
        // If setter is "setNumber:". This will return "number"
        return propertyNameWithUppercase
    }
    if object.responds(to: NSSelectorFromString("is" + propertyNameWithUppercase)) {
        // If setter is "setNumber:". This will return "number"
        return propertyName
    }
    return nil
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

private var isSupportedKVOAssociatedKey = 0
func isSupportedKVO(object: NSObject) throws -> Bool {
    if let isSupportedKVO = objc_getAssociatedObject(object, &isSupportedKVOAssociatedKey) as? Bool {
        return isSupportedKVO
    }
    guard let isaClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    let result: Bool
    if try isKVOed(object: object) {
        result = true
    } else {
        do {
            try SwiftHookUtilities.catchException {
                object.addObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, options: .new, context: &swiftHookKVOContext)
            }
            defer {
                object.removeObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, context: &swiftHookKVOContext)
            }
            guard let isaClassNew = object_getClass(object) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            result = isaClass != isaClassNew
        } catch {
            result = false
        }
    }
    objc_setAssociatedObject(object, &isSupportedKVOAssociatedKey, result, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    return result
}

private let KVOPrefix = "NSKVONotifying_"
func isKVOed(object: NSObject) throws -> Bool {
    // Can't check this in some special cases. Because when some objects be removed all observers. The class is still NSKVONotifying_XXX and the observationInfo is nil. For more detail: search test cases "test_unsuport_KVO_cancellation"
//    guard object.observationInfo != nil else {
//        return false
//    }
    guard let isaClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    let typeClass: AnyClass = type(of: object)
    guard isaClass != typeClass else {
        return false
    }    
    var tempClass: AnyClass? = isaClass
    while let currentClass = tempClass, currentClass != typeClass {
        if NSStringFromClass(currentClass).hasPrefix(KVOPrefix + NSStringFromClass(class_getSuperclass(currentClass)!)) {
            return true
        }
        tempClass = class_getSuperclass(currentClass)
    }
    return false
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
