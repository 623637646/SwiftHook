//
//  ClassInstanceHook.swift
//  SwiftHook
//
//  Created by Florian Zand on 16.05.25.
//

import Foundation


/// Hooks methods of all instances of a class.
public struct ClassInstanceHook<T: AnyObject> {
    let targetClass: AnyClass

    public init(_ targetClass: T.Type) {
        self.targetClass = targetClass
    }
    
    // MARK: - Hook Before

    /**
     Execute the closure before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
          
     try! ClassInstanceHook(MyObject.self).hookBefore(#selector(MyObject.sum(_:_:)) {
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
        try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure before the execution of object's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Token {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)) { obj, sel in
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Token {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Token {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).ClassInstanceHook(MyObject.self).hookBefore(#selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be AnyObject or your class (When it's your class).
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> Token {
        return try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be AnyObject or your class (When it's your class).
        2. The second parameter has to be `Selector`.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: String, closure: Any) throws -> Token {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
    // MARK: - Hook After
    
    /**
     Execute the closure after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).ClassInstanceHook(MyObject.self).hookAfter(#selector(MyObject.sum(_:_:)) {
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
        try hookAfter(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure after the execution of object's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> Token {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
        
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)) { obj, sel in
        print("hooked")
     }
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Token {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Token {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
        
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).ClassInstanceHook(MyObject.self).hookAfter(#selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
        print("hooked", number1, number2)
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class).
        2. The second parameter has to be Selector.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> Token {
        return try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be `AnyObject` or your class (When it's your class).
        2. The second parameter has to be Selector.
        3. The rest parameters are the same as the method's.
        4. The return type has to be Void.
        5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: String, closure: Any) throws -> Token {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    // MARK: - Hook
    
    /**
     Replace the implementation of object's method by the closure.
     
     Example usage:

     ```
     class MyObject {
        @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
            return number1 + number2
        }
     }
     
     try! ClassInstanceHook(MyObject.self).hook(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
        return original(obj, sel, number1, numebr2) * 2
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
     ```
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
        2. The second parameter has to be AnyObject or your class (When it's your class).
        3. The third parameter has to be `Selector`.
        4. The rest parameters are the same as the method's.
        5. The return type has to be the same as the original method's.
        6. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> Token {
        return try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: selector, mode: .instead, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Replace the implementation of object's method by the closure.
     
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure as following:
        1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
        2. The second parameter has to be AnyObject or your class (When it's your class).
        3. The third parameter has to be `Selector`.
        4. The rest parameters are the same as the method's.
        5. The return type has to be the same as the original method's.
        6. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hook(_ selector: String, closure: Any) throws -> Token {
        try hook(NSSelectorFromString(selector), closure: closure)
    }
}

// MARK: Hook Dealloc
public extension ClassInstanceHook where T: NSObject {
    
    /**
     Execute the closure before the object deinit.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeallocBefore {
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> Token {
        return try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .before, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
        }
    }
    
    /**
     Execute the closure with the object before the object deinit.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeallocBefore { object in
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping (_ object: T) -> Void) throws -> Token {
        let closure = { obj in
            guard let obj = obj as? T else { fatalError() }
            closure(obj)
        } as @convention(block) (NSObject) -> Void
        return try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .before, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
        }
    }
        
    /**
     Execute the closure after the object deinit.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDeallocAfter {
        print("hooked")
     }
     ```
     
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> Token {
        return try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .after, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
        }
    }
        
    /**
     Replace the implementation of object's deinit method by the closure.
     
     Example usage:
     
     ```
     try! ClassInstanceHook(MyObject.self).hookDealloc { original in
        print("before release")
        original()
        print("after release")
     }
     ```
     
     - Parameter closure: The hook closure with the original dealloc method as parameter. You have to call it to avoid memory leak.
     - Returns: The token of this hook behavior. You may cancel this hook through this token.
     
     - Note: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     */
    @discardableResult
    func hookDealloc(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> Token {
        try swiftHookSerialQueue.sync { () -> Token in
            try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .instead, closure: closure as AnyObject)
            return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
        }
    }
}

// MARK: - Hook Property

public extension ClassInstanceHook {
    @discardableResult
    func hookBefore<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Token {
        try hookBefore(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookBefore<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Token {
        try hookBefore(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Token {
        try hookAfter(try keyPath.getterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hookAfter<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value)->()) throws -> Token {
        try hookAfter(try keyPath.setterName(), closure: { obj, sel, val in
            guard let val = val as? Value, let obj = obj as? T else { return }
            closure(obj, val)
        } as @convention(block) (AnyObject, Selector, Any) -> Void )
    }
    
    @discardableResult
    func hook<Value>(_ keyPath: KeyPath<T, Value>, closure: @escaping (_ object: T, _ original: Value)->(Value)) throws -> Token {
        try hook(try keyPath.getterName(), closure: { original, obj, sel in
            if let value = original(obj, sel) as? Value, let obj = obj as? T {
                return closure(obj, value)
            }
            return original(obj, sel)
        } as @convention(block) ((AnyObject, Selector) -> Any,
                                 AnyObject, Selector) -> Any)
    }
    
    @discardableResult
    func hook<Value>(set keyPath: WritableKeyPath<T, Value>, closure: @escaping (_ object: T, _ value: Value, _ original: (Value)->())->()) throws -> Token {
        try hook(try keyPath.setterName(), closure: { original, obj, sel, val in
            if let val = val as? Value, let ob = obj as? T {
                let original: (Value)->() = { original(obj, sel, $0) }
                closure(ob, val, original)
            } else {
                original(obj, sel, val)
            }
        } as @convention(block) ((AnyObject, Selector, Any) -> Void,
                                 AnyObject, Selector,  Any) -> Void)
    }
}
