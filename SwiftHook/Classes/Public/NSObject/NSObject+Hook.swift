//
//  HookSpecificInstanceOC.swift
//  SwiftHook
//
//  Created by Yanni Wang on 25/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import Foundation

public extension NSObject {
    
    // MARK: - empty closure

    // before
    /**
     Execute the closure before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookBefore(#selector(MyObject.sum(with:number2:))) {
        print("hooked before")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    // after
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookAfter(#selector(MyObject.sum(with:number2:))) {
        print("hooked after")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure as Any)
    }

    // MARK: - custom closure

    // before
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookBefore(#selector(MyObject.sum(with:number2:))) { object, selector, num1, num2 in
         print("hooked before sum with \(n1), \(n2)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `(Self, Selector, ...)`. Return type: `Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookBefore(selector, closure: closure)
    }

    // after
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookAfter(#selector(MyObject.sum(with:number2:))) { object, selector, num1, num2 in
     print("hooked after sum with \(n1), \(n2)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `(Self, Selector, ...)`. Return type: `Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookAfter(selector, closure: closure)
    }

    // instead
    /**
     Replace the implementation of object's method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         @objc func sum(of number1: Int, and number2: Int) -> Int { return number1 + number2 }
     }
     
     try MyObject().hook(#selector(MyObject.sum(of:and:))) { original, obj, sel, n1, n2 in
         print("instead of sum")
         return original(obj, sel, n1, n2) * 2
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int
     
     // returns 6
     MyObject().sum(of: 1, and: 2)
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. Parameters: `((Self, Selector, ...) -> ReturnType, Self, Selector, ...) -> ReturnType`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hook(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    func hook(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hook(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookBefore(#selector(MyObject.sum(with:number2:))) { obj, sel in
         print("before sum of \(obj)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ObjectHook(self).hookBefore(selector) { obj, sel in
            guard let typedObj = obj as? Self else { fatalError() }
            closure(typedObj, sel)
        }
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject().hookAfter(#selector(MyObject.sum(with:number2:))) { obj, sel in
         print("after sum of \(obj)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. Parameters: `(Self, Selector) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ObjectHook(self).hookAfter(selector) { obj, sel in
            guard let typedObj = obj as? Self else { fatalError() }
            closure(typedObj, sel)
        }
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocBefore { obj in
        print("before dealloc of \(obj)")
     }
     ```
     - parameter closureObj: The hook closure. Parameter: `(Self) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles. Do not capture strong references to the object.
     */
    @discardableResult
    public func hookDeallocBefore(_ closure: @escaping (Self) -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocBefore { object in
            guard let typedObject = object as? Self else { fatalError() }
            closure(typedObject)
        }
    }
}

public extension NSObject {
    // MARK: before deinit
    
    /**
     Execute the closure before the object dealloc.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocBefore {
        print("before dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping () -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocBefore(closure: closure)
    }

    // MARK: after deinit
    
    /**
     Execute the closure after the object dealloc.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocAfter {
        print("after dealloc")
     }
     ```
     - parameter closure: The hook closure. Parameter: `() -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles.
     */
    @discardableResult
    func hookDeallocAfter(closure: @escaping () -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocAfter(closure: closure)
    }

    // MARK: replace deinit

    /**
     Replace the implementation of object's dealloc method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject { deinit { print("dealloc") } }
     
     try MyObject().hookDeallocInstead { original in
         print("instead of dealloc")
         original()
     }
     ```
     - parameter closure: The hook closure. Parameter: `(() -> Void) -> Void`.
     - returns: The token of this hook. You may cancel or reapply the hook through the token.
     
     - Note: The object will retain the closure. Avoid retain cycles. Call `original()` to prevent memory leaks.
     */
    @discardableResult
    func hookDeallocInstead(closure: @escaping (_ original: () -> Void) -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocInstead(closure: closure)
    }
}
