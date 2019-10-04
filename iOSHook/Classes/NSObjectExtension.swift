//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

// domain
public let domain = "com.iOSHook"
public enum ErrorCode: Int {
    case selectorNotAllowed = 0
}


// lock
private var lock = os_unfair_lock()
func performLocked(block: () -> Void) -> Void {
    os_unfair_lock_lock(&lock)
    block()
    os_unfair_lock_unlock(&lock)
}

// check selector
private let blacklist = [NSSelectorFromString("retain"),NSSelectorFromString("release"), NSSelectorFromString("autorelease"), NSSelectorFromString("forwardInvocation:")]
func isSelectorAllowed(
    class: AnyClass,
    selector: Selector,
    error: AutoreleasingUnsafeMutablePointer<Error>? = nil) -> Bool {
    guard !blacklist.contains(selector) else {
        error?.pointee = NSError.init(domain: domain, code: ErrorCode.selectorNotAllowed.rawValue, userInfo: nil)
        return false
    }
    return true
}

extension NSObject {
    
    // instance
    
    // after
    @discardableResult
    func hookAfter(selector: Selector,
                   onlyOnce: Bool = false,
                   error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
                   block: (_ obj: NSObject, _ result: Any, _ args: [Any]) -> Void) -> Token? {
        var token: Token? = nil
        performLocked {
            guard let `class` = object_getClass(self),
                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
                    return
            }
            token = Token()
        }
        return token
    }
    
    // before
    @discardableResult
    func hookBefore(selector: Selector,
                    onlyOnce: Bool = false,
                    error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
                    block: (_ obj: NSObject, _ args: [Any]) -> Void) -> Token? {
        var token: Token? = nil
        performLocked {
            guard let `class` = object_getClass(self),
                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
                    return
            }
            token = Token()
        }
        return token
    }
    
    // instead
    @discardableResult
    func hookInstead<ReturnType>(selector: Selector,
                                 onlyOnce: Bool = false,
                                 error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
                                 block: (_ obj: NSObject, _ origin: (_ args: [Any]) -> ReturnType, _ args: [Any]) -> ReturnType) -> Token? {
        var token: Token? = nil
        performLocked {
            guard let `class` = object_getClass(self),
                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
                    return
            }
            token = Token()
        }
        return token
    }
    
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
    
    // after
    @discardableResult
    class func hookAfter(selector: Selector,
                         isClassFunc: Bool = false,
                         onlyOnce: Bool = false,
                         error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
                         block: (_ obj: NSObject, _ result: Any, _ args: [Any]) -> Void) -> Token? {
        var token: Token? = nil
        performLocked {
            guard let `class` = object_getClass(self),
                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
                    return
            }
            token = Token()
        }
        return token
    }
    
    // before
    @discardableResult
    class func hookBefore(selector: Selector,
                          isClassFunc: Bool = false,
                          onlyOnce: Bool = false,
                          error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
                          block: (_ obj: NSObject, _ args: [Any]) -> Void) -> Token? {
        var token: Token? = nil
        performLocked {
            guard let `class` = object_getClass(self),
                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
                    return
            }
            token = Token()
        }
        return token
    }
    
    // instead
    @discardableResult
    class func hookInstead<ReturnType>(selector: Selector,
                                       isClassFunc: Bool = false,
                                       onlyOnce: Bool = false,
                                       error: AutoreleasingUnsafeMutablePointer<Error>? = nil,
                                       block: (_ obj: NSObject, _ origin: (_ args: [Any]) -> ReturnType, _ args: [Any]) -> ReturnType) -> Token? {
        var token: Token? = nil
        performLocked {
            guard let `class` = object_getClass(self),
                isSelectorAllowed(class: `class`, selector: selector, error: error) else {
                    return
            }
            token = Token()
        }
        return token
    }
    
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
