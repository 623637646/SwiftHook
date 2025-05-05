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

extension NSObject {
    func isSupportedKVO() throws -> Bool {
        if let isSupportedKVO: Bool = getAssociatedValue("isSupportedKVO", object: self) {
            return isSupportedKVO
        }
        guard let isaClass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let result: Bool
        if try isKVOed() {
            result = true
        } else {
            do {
                try SwiftHookUtilities.catchException {
                    addObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, options: .new, context: &swiftHookKVOContext)
                }
                defer {
                    removeObserver(RealObserver.shared, forKeyPath: swiftHookKeyPath, context: &swiftHookKVOContext)
                }
                guard let isaClassNew = object_getClass(self) else {
                    throw SwiftHookError.internalError(file: #file, line: #line)
                }
                result = isaClass != isaClassNew
            } catch {
                result = false
            }
        }
        setAssociatedValue(result, key: "isSupportedKVO", object: self)
        return result
    }
    
    func wrapKVOIfNeeded(selector: Selector) throws {
        if swiftHookObserver == nil {
            swiftHookObserver = Observer(target: self)
        }
        guard let KVOedClass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        if getMethodWithoutSearchingSuperClasses(targetClass: KVOedClass, selector: selector) == nil,
           let propertyName = try getKVOName(setter: selector) {
            guard let observer = swiftHookObserver else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            // With this code. `getMethodWithoutSearchingSuperClasses(targetClass: KVOedClass, selector: selector)` will be non-nil.
            addObserver(observer, forKeyPath: propertyName, options: .new, context: &swiftHookKVOContext)
            removeObserver(observer, forKeyPath: propertyName, context: &swiftHookKVOContext)
        }
    }
    
    func unwrapKVOIfNeeded() {
        guard swiftHookObserver != nil else {
            return
        }
        swiftHookObserver = nil
    }
    
    // return nil if the selector is not a setter.
    private func getKVOName(setter: Selector) throws -> String? {
        let setterName = NSStringFromSelector(setter)
        guard setterName.hasPrefix("set") && setterName.hasSuffix(":") else {
            return nil
        }
        let propertyNameWithUppercase = String(setterName.dropFirst("set".count).dropLast(":".count))
        guard let firstCharacter = propertyNameWithUppercase.first else {
            return nil
        }
        let firstCharacterLowercase = firstCharacter.lowercased()
        let propertyName = firstCharacterLowercase + propertyNameWithUppercase.dropFirst()
        guard let baseClass = object_getClass(self) else {
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
        if responds(to: NSSelectorFromString(propertyName)) {
            // If setter is "setNumber:". This will return "number"
            return propertyName
        }
        if responds(to: NSSelectorFromString(propertyNameWithUppercase)) {
            // If setter is "setNumber:". This will return "number"
            return propertyNameWithUppercase
        }
        if responds(to: NSSelectorFromString("is" + propertyNameWithUppercase)) {
            // If setter is "setNumber:". This will return "number"
            return propertyName
        }
        return nil
    }
    
    private func isKVOed() throws -> Bool {
        // Can't check this in some special cases. Because when some objects be removed all observers. The class is still NSKVONotifying_XXX and the observationInfo is nil. For more detail: search test cases "test_unsuport_KVO_cancellation"
    //    guard object.observationInfo != nil else {
    //        return false
    //    }
        guard let isaClass = object_getClass(self) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        let typeClass: AnyClass = type(of: self)
        guard isaClass != typeClass else {
            return false
        }
        var tempClass: AnyClass? = isaClass
        while let currentClass = tempClass, currentClass != typeClass {
            if NSStringFromClass(currentClass).hasPrefix("NSKVONotifying_" + NSStringFromClass(class_getSuperclass(currentClass)!)) {
                return true
            }
            tempClass = class_getSuperclass(currentClass)
        }
        return false
    }
    
    private var swiftHookObserver: Observer? {
        get { getAssociatedValue("swiftHookObserver", object: self) }
        set { setAssociatedValue(newValue, key: "swiftHookObserver", object: self) }
    }
}

fileprivate class RealObserver: NSObject {
    static let shared = RealObserver()
    
    private override init() {
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != swiftHookKeyPath else { return }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}

fileprivate class Observer: NSObject {
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

fileprivate var swiftHookKVOContext = 0
fileprivate let swiftHookKeyPath = "swiftHookPrivateProperty"
