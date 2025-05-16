//
//  ClassHook.swift
//  SwiftHook
//
//  Created by Florian Zand on 16.05.25.
//

import Foundation

/// Hooks class methods.
public struct ClassHook<T: AnyObject> {
    let targetClass: AnyClass

    public init(_ targetClass: T.Type) {
        self.targetClass = targetClass
    }
    
    // MARK: - Before
    
    /**
     Execute the closure before the execution of class's method.
     
     Example usage:
     
     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hookBefore(#selector(MyObject.sum(_:_:)) {
        print("hooked")
     }
     ```

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
        return try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure before the execution of class's method.

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Token {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector before the execution of class's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hookBefore(#selector(MyObject.sum(_:_:)) { obj, sel in
        print("hooked")
     }
     ```

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ class: T.Type, _ selector: Selector) -> Void) throws -> Token {
        let closure = { obj, sel in
            guard let obj = obj as? T.Type else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure with the object and the selector before the execution of class's method.

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping (_ `class`: T.Type, _ selector: Selector) -> Void) throws -> Token {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with all parameters before the execution of class's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hookBefore(#selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class.
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be `Void`.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> Token {
        guard let targetClass = object_getClass(targetClass) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return try swiftHookSerialQueue.sync {
            try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Execute the closure with all parameters before the execution of class's method.

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class.
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be `Void`.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: String, closure: Any) throws -> Token {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    // MARK: - After
    
    /**
     Execute the closure after the execution of class's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hookAfter(#selector(MyObject.sum(_:_:)) {
        print("hooked")
     }
     ```

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
        return try hookAfter(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure after the execution of class's method.

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Token {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
            
    /**
     Execute the closure with the object and the selector after the execution of class's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hookAfter(#selector(MyObject.sum(_:_:)) { obj, sel in
        print("hooked")
     }
     ```

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ class: T.Type, _ selector: Selector) -> Void) throws -> Token {
        let closure = { obj, sel in
            guard let obj = obj as? T.Type else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of class's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping (_ `class`: T.Type, _ selector: Selector) -> Void) throws -> Token {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with all parameters after the execution of class's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hookAfter(#selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class.
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be `Void`.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> Token {
        guard let targetClass = object_getClass(targetClass) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return try swiftHookSerialQueue.sync {
            try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Execute the closure with all parameters after the execution of class's method.

     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class.
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be `Void`.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: String, closure: Any) throws -> Token {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    // MARK: - Instead
    
    /**
     Replace the implementation of class's method by the closure.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic class func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassHook(MyObject.self).hook(#selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
        return original(obj, sel, number1, numebr2) * 2
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain `AnyObject` and `Selector` at the beginning)..
        2. The second parameter has to be `AnyObject` or your class (When it's your class.
        3. The third parameter has to be `Selector`.
        4. The rest parameters are the same as the method's.
        5. The return type has to be the same as the original method's.
        6. The keyword `@convention(block)` is necessary,
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> Token {
        guard let targetClass = object_getClass(targetClass) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return try swiftHookSerialQueue.sync {
            try parametersCheck(targetClass: targetClass, selector: selector, mode: .instead, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Replace the implementation of class's method by the closure.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain `AnyObject` and `Selector` at the beginning)..
        2. The second parameter has to be `AnyObject` or your class (When it's your class.
        3. The third parameter has to be `Selector`.
        4. The rest parameters are the same as the method's.
        5. The return type has to be the same as the original method's.
        6. The keyword `@convention(block)` is necessary,
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hook(_ selector: String, closure: Any) throws -> Token {
        try hook(NSSelectorFromString(selector), closure: closure)
    }
}

public extension ClassHook {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class_: T.Type, _ value: Value)->()) throws -> Token {
        try hookBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T.Type else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class_: T.Type, _ value: Value)->()) throws -> Token {
        try hookBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T.Type else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class_: T.Type, _ value: Value)->()) throws -> Token {
        try hookAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T.Type else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class_: T.Type, _ value: Value)->()) throws -> Token {
        try hookAfter(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T.Type else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T.Type, Value>, closure: @escaping (_ class_: T.Type, _ original: Value)->(Value)) throws -> Token {
        try hook(try keyPath.getterName(), closure: { original, obj, sel in
            if let value = original(obj, sel) as? Value, let obj = obj as? T.Type {
                return closure(obj, value)
            }
            return original(obj, sel)
        } as @convention(block) ((AnyObject, Selector) -> Any,
                                 AnyObject, Selector) -> Any)
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T.Type, Value>, closure: @escaping (_ class_: T.Type, _ value: Value, _ original: (Value)->())->()) throws -> Token {
        try hook(try keyPath.setterName(), closure: { original, obj, sel, val in
            if let val = val as? Value, let ob = obj as? T.Type {
                let original: (Value)->() = { original(obj, sel, $0) }
                closure(ob, val, original)
            } else {
                original(obj, sel, val)
            }
        } as @convention(block) ((AnyObject, Selector, Any) -> Void,
                                 AnyObject, Selector,  Any) -> Void)
    }
}
