//
//  HookClassMethodsOC.swift
//  SwiftHook
//
//  Created by Yanni Wang on 25/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import Foundation

public extension NSObject {
    /**
     Execute the closure before the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClassBefore(#selector(MyObject.sum(with:number2:))) {
         print("hooked before class sum")
     }
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassBefore(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookClassBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookClassBefore(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookClassBefore(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    /**
     Execute the closure after the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClassAfter(#selector(MyObject.sum(with:number2:))) {
         print("hooked after class sum")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassAfter(_ selector: Selector, closure: @escaping () -> Void) throws -> HookToken {
        try hookClassAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookClassAfter(_ selector: String, closure: @escaping () -> Void) throws -> HookToken {
        try hookClassAfter(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    // MARK: - custom closure
    
    /**
     Execute the closure with all parameters before the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClassBefore(#selector(MyObject.sum(with:number2:))) { (obj: NSObject, sel: Selector, number1: Int, number2: Int) in
         print("hooked before class sum with \(number1) and \(number2)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    class func hookClassBefore(_ selector: String, closure: Any) throws -> HookToken {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    /**
     Execute the closure with all parameters after the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClassAfter(#selector(MyObject.sum(with:number2:))) { (obj: NSObject, sel: Selector, number1: Int, number2: Int) in
         print("hooked after class sum with \(number1) and \(number2)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be `NSObject`.
         2. The second parameter has to be `Selector`.
         3. The rest parameters are the same as the method's.
         4. The return type has to be `Void`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    class func hookClassAfter(_ selector: String, closure: Any) throws -> HookToken {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    /**
     Replace the implementation of class's method by the closure.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(of number1: Int, and number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClass(#selector(MyObject.sum(of:and:))) { (original: @escaping (NSObject.Type, Selector, Int, Int) -> Int, obj: NSObject.Type, sel: Selector, number1: Int, number2: Int) -> Int in
         print("hooked instead of class sum")
         return original(obj, sel, number1, number2) * 3
     }
     
     // Returns 9
     MyObject.sum(of: 1, and: 2)
     ```

     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be a closure. This closure represents the original method. Its parameters and return type are the same as the original method's (The parameters contain `Self.Type` and `Selector` at the beginning).
         2. The second parameter has to be `NSObject.Type`.
         3. The third parameter has to be `Selector`.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClass(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassHook(self).hook(selector, closure: closure)
    }
    
    @discardableResult
    class func hookClass(_ selector: String, closure: Any) throws -> HookToken {
        try ClassHook(self).hook(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the class and the selector before the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClassBefore(#selector(MyObject.sum(with:number2:))) { class_, sel in
         print("hooked before class sum on \(class_)")
     }
     ```
     
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookClassBefore(_ selector: Selector, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        try ClassHook(self).hookBefore(selector) { _class, sel in
            guard let _class = _class as? Self.Type else { fatalError() }
            closure(_class, sel)
        }
    }
    
    @discardableResult
    static func hookClassBefore(_ selector: String, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        try hookClassBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the class and the selector after the execution of class's method.
     
     Example usage:
     
     ```swift
     class MyObject: NSObject {
         class func sum(with number1: Int, number2: Int) -> Int {
             return number1 + number2
         }
     }
     
     try MyObject.hookClassAfter(#selector(MyObject.sum(with:number2:))) { class_, sel in
         print("hooked after class sum on \(class_)")
     }
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookClassAfter(_ selector: Selector, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        try ClassHook(self).hookAfter(selector) { _class, sel in
            guard let _class = _class as? Self.Type else { fatalError() }
            closure(_class, sel)
        }
    }
    
    @discardableResult
    static func hookClassAfter(_ selector: String, closure: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        try hookClassAfter(NSSelectorFromString(selector), closure: closure)
    }
}
