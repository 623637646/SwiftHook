//
//  KVODynamicClass.swift
//  SwiftHook
//
//  Created by Wang Ya on 12/27/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private class Observer: NSObject {
    
    private static let keyPath = "swiftHookPrivateProperty"
        
    private unowned(unsafe) let target: NSObject
    
    init(target: NSObject) {
        self.target = target
        super.init()
        target.addObserver(self, forKeyPath: Observer.keyPath, options: .new, context: nil)
    }
    
    deinit {
        self.target.removeObserver(self, forKeyPath: Observer.keyPath)
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
       let propertyName = getGetterMethodName(object: object, selector: selector) {
        guard let observer = object.swiftHookObserver else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        object.addObserver(observer, forKeyPath: propertyName, options: .new, context: nil)
        object.removeObserver(observer, forKeyPath: propertyName)
    }
}

private let setMethodPrefix = "set"
private let setMethodSuffix = ":"
// return nil if the selector is not a setter.
func getGetterMethodName(object: NSObject, selector: Selector) -> String? {
    let selectorName = NSStringFromSelector(selector)
    guard selectorName.hasPrefix(setMethodPrefix) && selectorName.hasSuffix(setMethodSuffix) else {
        return nil
    }
    let propertyNameWithUppercase = String(selectorName.dropFirst(setMethodPrefix.count).dropLast(setMethodSuffix.count))
    guard let firstCharacter = propertyNameWithUppercase.first else {
        return nil
    }
    guard firstCharacter.isUppercase else {
        return nil
    }
    let firstCharacterLowercase = firstCharacter.lowercased()
    let propertyName = firstCharacterLowercase + propertyNameWithUppercase.dropFirst()
    let setterSelector = NSSelectorFromString(propertyName)
    guard object.responds(to: setterSelector) else {
        return nil
    }
    return propertyName
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
