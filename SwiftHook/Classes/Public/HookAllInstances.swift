//
//  HookAllInstances.swift
//  SwiftHook
//
//  Created by Yanni Wang on 24/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import Foundation

// MARK: - empty closure

// before
/**
 Execute the closure before the execution of object's method.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: {
     print("hooked")
 })
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    return try hookBefore(targetClass: targetClass, selector: selector, closure: closure as Any)
}

// after
/**
 Execute the closure after the execution of object's method.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: {
     print("hooked")
 })
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> Token {
    return try hookAfter(targetClass: targetClass, selector: selector, closure: closure as Any)
}

// MARK: - self and selector closure

// before
/**
 Execute the closure with the object and the selector before the execution of object's method.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel in
     print("hooked")
 })
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookBefore<T: AnyObject>(targetClass: T.Type, selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Token {
    let closure = { obj, sel in
        guard let obj = obj as? T else { fatalError() }
        closure(obj, sel)
    } as @convention(block) (AnyObject, Selector) -> Void
    return try hookBefore(targetClass: targetClass, selector: selector, closure: closure as Any)
}

// after
/**
 Execute the closure with the object and the selector after the execution of object's method.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel in
     print("hooked")
 })
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookAfter<T: AnyObject>(targetClass: T.Type, selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> Token {
    let closure = { obj, sel in
        guard let obj = obj as? T else { fatalError() }
        closure(obj, sel)
    } as @convention(block) (AnyObject, Selector) -> Void
    return try hookAfter(targetClass: targetClass, selector: selector, closure: closure as Any)
}

// MARK: - custom closure

// before
/**
 Execute the closure with all parameters before the execution of object's method.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
     print("hooked")
 } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure. The following is a description of the closure
     1. The first parameter has to be AnyObject or YOUR CLASS (When it's YOUR CLASS. The class has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
     2. The second parameter has to be Selector.
     3. The rest parameters are the same as the method's.
     4. The return type has to be Void.
     5. The keyword `@convention(block)` is necessary
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    return try swiftHookSerialQueue.sync { () -> Token in
        try parametersCheck(targetClass: targetClass, selector: selector, mode: .before, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: selector, mode: .before, hookClosure: closure as AnyObject)
    }
}

// after
/**
 Execute the closure with all parameters after the execution of object's method.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
     print("hooked")
 } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure. The following is a description of the closure
     1. The first parameter has to be AnyObject or YOUR CLASS (When it's YOUR CLASS. The class has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
     2. The second parameter has to be Selector.
     3. The rest parameters are the same as the method's.
     4. The return type has to be Void.
     5. The keyword `@convention(block)` is necessary
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    return try swiftHookSerialQueue.sync { () -> Token in
        try parametersCheck(targetClass: targetClass, selector: selector, mode: .after, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: selector, mode: .after, hookClosure: closure as AnyObject)
    }
}

// instead
/**
 Replace the implementation of object's method by the closure.
 
 # Example
 ```
 class MyObject {
     @objc dynamic func sum(_ number1: Int, _ number2: Int) -> Int {
         return number1 + number2
     }
 }
 let token = try! hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
     // You may call the original method with some different parameters. You can even not call the original method.
     return original(obj, sel, number1, numebr2)
 } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
 _ = MyObject().sum(1, 2)
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It doesn’t have to be inherited from NSObject.
 - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
 - parameter closure: The hook closure. The following is a description of the closure
     1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
     2. The second parameter has to be AnyObject or YOUR CLASS (When it's YOUR CLASS. The class has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
     3. The third parameter has to be Selector.
     4. The rest parameters are the same as the method's.
     5. The return type has to be the same as the original method's.
     6. The keyword `@convention(block)` is necessary
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> Token {
    return try swiftHookSerialQueue.sync { () -> Token in
        try parametersCheck(targetClass: targetClass, selector: selector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: selector, mode: .instead, hookClosure: closure as AnyObject)
    }
}

// MARK: before deinit

/**
 Execute the closure before the object deinit.
 
 # Example
 ```
 class MyObject: NSObject {
 }
 let token = try! hookDeallocBefore(targetClass: MyObject.self, closure: {
     print("hooked")
 })
 autoreleasepool {
     let object = MyObject()
 }
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
 - parameter closure: The hook closure.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookDeallocBefore(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    return try swiftHookSerialQueue.sync { () -> Token in
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .before, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

/**
 Execute the closure with the object before the object deinit.
 
 # Example
 ```
 class MyObject: NSObject {
 }
 let token = try! hookDeallocBefore(targetClass: MyObject.self, closure: { obj in
     print("hooked")
 })
 autoreleasepool {
     let object = MyObject()
 }
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
 - parameter closure: The hook closure.
 
   **WARNING**: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released. Otherwise it crashs on:
     1. `malloc: *** error for object: pointer being freed was not allocated`
     2. `Cannot form weak reference to instance of class xxx. It is possible that this object was over-released, or is in the process of deallocation.`
     3. `EXC_BAD_ACCESS`.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookDeallocBefore<T: NSObject>(targetClass: T.Type, closure: @escaping (_ object: T) -> Void) throws -> Token {
    let closure = { obj in
        guard let obj = obj as? T else { fatalError() }
        closure(obj)
    } as @convention(block) (NSObject) -> Void
    return try swiftHookSerialQueue.sync { () -> Token in
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .before, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)
    }
}

// MARK: after deinit

/**
 Execute the closure after the object deinit.
 
 # Example
 ```
 class MyObject: NSObject {
 }
 let token = try! hookDeallocAfter(targetClass: MyObject.self, closure: {
     print("hooked")
 })
 autoreleasepool {
     let object = MyObject()
 }
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
 - parameter closure: The hook closure.
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookDeallocAfter(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> Token {
    return try swiftHookSerialQueue.sync { () -> Token in
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .after, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)
    }
}

// MARK: replace deinit

/**
 Replace the implementation of object's deinit method by the closure.
 
 # Example
 ```
 class MyObject: NSObject {
 }
 let token = try! hookDeallocInstead(targetClass: MyObject.self, closure: { original in
     print("before release")
     original()
     print("after release")
 })
 autoreleasepool {
     let object = MyObject()
 }
 token.cancelHook() // cancel hook
 ```
 - parameter targetClass: The class you want to hook on. It has to be inherited from NSObject.
 - parameter closure: The hook closure.
 
 - parameter original: The original dealloc method.
 
     **WARNING**: Have to call original to avoid memory leak.
 
 - returns: The token of this hook behavior. You may cancel this hook through this token.
 */
@discardableResult
public func hookDeallocInstead(targetClass: NSObject.Type, closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> Token {
    try swiftHookSerialQueue.sync { () -> Token in 
        try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .instead, closure: closure as AnyObject)
        return try internalHook(targetClass: targetClass, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)
    }
}
