//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

public protocol iOSHookProtocol {
}

extension NSObject: iOSHookProtocol {
}

public extension iOSHookProtocol where Self: NSObject {
    
    // MARK: Before
    @discardableResult
    func hookSelfAtBefore<T>(selector: Selector,
                             onlyOnce: Bool = false,
                             block: (_ obj: Self, _ args: T) -> Void) throws -> Token? {
        var token: Token? = nil
        try performLocked {
            guard try isSelectorAllowedForInstances(theClass: type(of: self), selector: selector) else {
                return
            }
            token = try hook(instance: InstanceHookContainer(obj: self, selector: selector, onlyOnce: onlyOnce))
        }
        return token
    }
    
    @discardableResult
    static func hookAllInstancesAtBefore<T>(selector: Selector,
                                            onlyOnce: Bool = false,
                                            block: (_ obj: Self, _ args: T) -> Void) throws -> Token? {
        var token: Token? = nil
        try performLocked {
            guard try isSelectorAllowedForInstances(theClass: self, selector: selector) else {
                return
            }
            token = Token()
        }
        return token
    }
    
    @discardableResult
    static func hookClassMethodAtBefore<T>(selector: Selector,
                                           onlyOnce: Bool = false,
                                           block: (_ args: T) -> Void) throws -> Token? {
        var token: Token? = nil
        try performLocked {
            guard try isSelectorAllowedForClass(theClass: self, selector: selector) else {
                return
            }
            token = Token()
        }
        return token
    }
    
    // MARK: After
//    @discardableResult
//    func hookAfter(selector: Selector,
//                   onlyOnce: Bool = false,
//                   error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                   block: (_ obj: NSObject, _ result: Any, _ args: [Any]) -> Void) -> Token? {
//        var token: Token? = nil
//        performLocked {
//            guard let `class` = object_getClass(self),
//                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
//                    return
//            }
//            token = Token()
//        }
//        return token
//    }
    
    // instead
//    @discardableResult
//    func hookInstead<ReturnType>(selector: Selector,
//                                 onlyOnce: Bool = false,
//                                 error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                                 block: (_ obj: NSObject, _ origin: (_ args: [Any]) -> ReturnType, _ args: [Any]) -> ReturnType) -> Token? {
//        var token: Token? = nil
//        performLocked {
//            guard let `class` = object_getClass(self),
//                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
//                    return
//            }
//            token = Token()
//        }
//        return token
//    }
    
//    // before dealloc
//    func hookBeforeDealloc(error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                           block: (_ obj: NSObject) -> Void) {
//        performLocked {
//
//        }
//    }
//
//    // after dealloc
//    func hookAfterDealloc(error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                          block: () -> Void) {
//        performLocked {
//
//        }
//    }
    
    // class
    
    // before
    
    
    // after
//    @discardableResult
//    class func hookAfter(selector: Selector,
//                         isClassFunc: Bool = false,
//                         onlyOnce: Bool = false,
//                         error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                         block: (_ obj: NSObject, _ result: Any, _ args: [Any]) -> Void) -> Token? {
//        var token: Token? = nil
//        performLocked {
//            guard let `class` = object_getClass(self),
//                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
//                    return
//            }
//            token = Token()
//        }
//        return token
//    }
    
    // instead
//    @discardableResult
//    class func hookInstead<ReturnType>(selector: Selector,
//                                       isClassFunc: Bool = false,
//                                       onlyOnce: Bool = false,
//                                       error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                                       block: (_ obj: NSObject, _ origin: (_ args: [Any]) -> ReturnType, _ args: [Any]) -> ReturnType) -> Token? {
//        var token: Token? = nil
//        performLocked {
//            guard let `class` = object_getClass(self),
//                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
//                    return
//            }
//            token = Token()
//        }
//        return token
//    }
//    
//    // before dealloc
//    class func hookBeforeDealloc(error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                                 block: (_ obj: NSObject) -> Void) {
//        performLocked {
//
//        }
//    }
//
//    // after dealloc
//    class func hookAfterDealloc(error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
//                                block: () -> Void) {
//        performLocked {
//
//        }
//    }
    
}
