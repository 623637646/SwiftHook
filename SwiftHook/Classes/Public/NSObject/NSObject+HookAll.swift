//
//  HookAllInstancesOC.swift
//  SwiftHook
//
//  Created by Yanni Wang on 25/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import Foundation

public extension NSObject {
    /**
     Execute the closure before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(with:number2:))) {
         print("hooked before sum")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookBefore(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(with:number2:))) {
         print("hooked after sum")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookAfter(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookBefore(#selector(MyObject.sum(with:number2:))) { (obj: MyObject, sel: Selector, number1: Int, number2: Int) in
         print("hooked before sum with \(number1) and \(number2)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `Self` or `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    class func hookBefore(_ selector: String, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(with:number2:))) { (obj: MyObject, sel: Selector, number1: Int, number2: Int) in
         print("hooked after sum with \(number1) and \(number2)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `Self` or `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    class func hookAfter(_ selector: String, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Replace the implementation of object's method by the closure.

     Example usage:
     
     ```swift
     class MyObject: NSObject {
         func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hook(#selector(MyObject.sum(of:and:))) { (original: @escaping (MyObject, Selector, Int, Int) -> Int, obj: MyObject, sel: Selector, number1: Int, number2: Int) -> Int in
         // You may call the original method with some different parameters. You can even not call the original method.
         return original(obj, sel, number1, number2) * 2
     }
     MyObject().sum(of: 1, and: 2)  // returns 6
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be a closure. This closure represents the original method. Its parameters and return type are the same as the original method's (The parameters contain `Self` and `Selector` at the beginning).
         2. The second parameter has to be `Self` or `NSObject`.
         3. The third parameter has to be `Selector`.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hook(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    class func hook(_ selector: String, closure: Any) throws -> HookToken {
        try ClassInstanceHook(self).hook(selector, closure: closure)
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
     
     try MyObject.hookBefore(#selector(MyObject.sum(with:number2:))) { object, selector in
         print("hooked \(object) before sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookBefore(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookBefore(selector) { obj, sel in
            guard let typedObj = obj as? Self else {
                assertionFailure("Failed to cast \(obj) to expected type \(Self.self)")
                return
            }
            closure(typedObj, sel)
        }
    }
    
    @discardableResult
    static func hookBefore(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     ```swift
     class MyObject: NSObject {
         func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookAfter(#selector(MyObject.sum(with:number2:))) { object, selector in
         print("hooked \(object) after sum")
     }
     ```
     
     - Parameters:
        - selector: The method you want to hook on.
        - closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookAfter(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookAfter(selector) { obj, sel in
            guard let typedObj = obj as? Self else {
                assertionFailure("Failed to cast \(obj) to expected type \(Self.self)")
                return
            }
            closure(typedObj, sel)
        }
    }
    
    @discardableResult
    static func hookAfter(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
}

public extension NSObject {
    // MARK: before deinit
    /**
     Execute the closure before the object dealloc.
     
     Example:
     
     ```swift
     NSTextField.hookDeallocBefore {
         print("hooked before dealloc of NSTextField")
     }
     ```
     
     - Parameter closure: The hook closure.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookDeallocBefore(closure: @escaping () -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocBefore(closure: closure)
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     ```swift
     NSTextField.hookDeallocBefore { object in
         print("hooked before dealloc of \(object)")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released.
     */
    @discardableResult
    class func hookDeallocBefore(closure: @escaping (_ object: NSObject) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocBefore(closure: closure)
    }
    
    // MARK: after deinit
    /**
     Execute the closure after the object dealloc.
     
     Example usage:
     
     ```swift
     NSTextField.hookDeallocAfter {
         print("hooked after dealloc of NSTextField")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookDeallocAfter(closure: @escaping () -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocAfter(closure: closure)
    }
    
    // MARK: replace deinit
    /**
     Replace the implementation of object's dealloc method by the closure.
     
     Example usage:
     
     ```swift
     NSTextField.hookDeallocInstead { (original: @escaping () -> Void) in
         print("before release of NSTextField")
         original()
         print("after release of NSTextField")
     }
     ```
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: You have to call `original()` to avoid memory leak.
     */
    @discardableResult
    class func hookDeallocInstead(closure: @escaping (_ original: () -> Void) -> Void) throws -> HookToken {
        try ClassInstanceHook(self).hookDeallocInstead(closure: closure)
    }
}
