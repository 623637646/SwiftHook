//
//  SwiftHook+ObjectHook.swift
//  SwiftHook
//
//  Created by Florian Zand on 05.05.25.
//

import Foundation

/// Hooks an object.
public struct ObjectHook<T: AnyObject> {
    let object: T
    
    public init(_ object: T) {
        self.object = object
    }
    
    
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
     let object = MyObject()
     let token = try! hookBefore(object: object, selector: #selector(MyObject.sum(_:_:)), closure: {
     print("hooked")
     })
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closure as Any)
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
     let object = MyObject()
     let token = try! hookAfter(object: object, selector: #selector(MyObject.sum(_:_:)), closure: {
     print("hooked")
     })
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closure as Any)
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
     let object = MyObject()
     let token = try! hookBefore(object: object, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel in
     print("hooked")
     })
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookBefore(selector, closure: closure as Any)
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
     let object = MyObject()
     let token = try! hookAfter(object: object, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel in
     print("hooked")
     })
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        let closure = { obj, sel in
            guard let obj = obj as? T else { fatalError() }
            closure(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try hookAfter(selector, closure: closure as Any)
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
     let object = MyObject()
     let token = try! hookBefore(object: object, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
     print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain. The following is a description of the closure
     1. The first parameter has to be AnyObject or YOUR CLASS (When it's YOUR CLASS. The class has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
     2. The second parameter has to be Selector.
     3. The rest parameters are the same as the method's.
     4. The return type has to be Void.
     5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try swiftHookSerialQueue.sync {
            try HookToken(for: object, selector: selector, mode: .before, hookClosure: closure as AnyObject)._apply()
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
     let object = MyObject()
     let token = try! hookAfter(object: object, selector: #selector(MyObject.sum(_:_:)), closure: { obj, sel, number1, number2 in
     print("hooked")
     } as @convention(block) (AnyObject, Selector, Int, Int) -> Void)
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain. The following is a description of the closure
     1. The first parameter has to be AnyObject or YOUR CLASS (When it's YOUR CLASS. The class has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
     2. The second parameter has to be Selector.
     3. The rest parameters are the same as the method's.
     4. The return type has to be Void.
     5. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try swiftHookSerialQueue.sync {
            try HookToken(for: object, selector: selector, mode: .after, hookClosure: closure as AnyObject)._apply()
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
     let object = MyObject()
     let token = try! hook(object: object, selector: #selector(MyObject.sum(_:_:)), closure: { original, obj, sel, number1, numebr2 in
     // You may call the original method with some different parameters. You can even not call the original method.
     return original(obj, sel, number1, numebr2)
     } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int )
     _ = object.sum(1, 2)
     token.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It doesn’t have to be inherited from NSObject.
     - parameter selector: The method you want to hook on.  It has to be declared with the keywords  `@objc` and `dynamic`.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain. The following is a description of the closure
     1. The first parameter has to be a closure. This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning).
     2. The second parameter has to be AnyObject or YOUR CLASS (When it's YOUR CLASS. The class has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
     3. The third parameter has to be Selector.
     4. The rest parameters are the same as the method's.
     5. The return type has to be the same as the original method's.
     6. The keyword `@convention(block)` is necessary
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hook(_ selector: Selector, closure: Any) throws -> HookToken {
        return try swiftHookSerialQueue.sync {
            return try HookToken(for: object, selector: selector, mode: .instead, hookClosure: closure as AnyObject)._apply()
        }
    }
    
    /**
     Execute the closure with the object before the object deinit.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     var token: HookToken?
     autoreleasepool {
     let object = MyObject()
     token = try! hookDeallocBefore(object: object, closure: { obj in
     print("hooked")
     })
     }
     token?.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure.
     
     **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     
     **WARNING**: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released. Otherwise it crashs on:
     1. `malloc: *** error for object: pointer being freed was not allocated`
     2. `Cannot form weak reference to instance of class xxx. It is possible that this object was over-released, or is in the process of deallocation.`
     3. `EXC_BAD_ACCESS`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookDeallocBefore(closure: @escaping (_ object: T) -> Void) throws -> HookToken {
        let closure = { obj in
            guard let obj = obj as? T else { fatalError() }
            closure(obj)
        } as @convention(block) (NSObject) -> Void
        return try swiftHookSerialQueue.sync {
            try HookToken(for: object, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)._apply()
        }
    }
    
    // MARK: after deinit
    
    /**
     Execute the closure after the object deinit.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     var token: HookToken?
     autoreleasepool {
     let object = MyObject()
     token = try! hookDeallocAfter(object: object, closure: {
     print("hooked")
     })
     }
     token?.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        return try swiftHookSerialQueue.sync {
            if let object = object as? NSObject {
                return try HookToken(for: object, selector: deallocSelector, mode: .after, hookClosure: closure as AnyObject)._apply()
            } else {
                return HookToken(deallocAfter: object, hookClosure: closure as AnyObject)
            }
        }
    }
}

extension ObjectHook where T: NSObject {
    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    public func hookBefore(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    public func hookAfter(_ selector: String, closure: @escaping (_ object: T, _ selector: Selector) -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
    
    @discardableResult
    public func hookBefore(_ selector: String, closure: Any) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    public func hookAfter(_ selector: String, closure: Any) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure)
    }

    @discardableResult
    public func hook(_ selector: String, closure: Any) throws -> HookToken {
        try hook(NSSelectorFromString(selector), closure: closure)
    }
}

public extension ObjectHook where T: NSObject {
    // MARK: before deinit
    /**
     Execute the closure before the object deinit.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     var token: HookToken?
     autoreleasepool {
     let object = MyObject()
     token = try! hookDeallocBefore(object: object, closure: {
     print("hooked")
     })
     }
     token?.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try swiftHookSerialQueue.sync {
            try HookToken(for: object, selector: deallocSelector, mode: .before, hookClosure: closure as AnyObject)._apply()
        }
    }
    
    // MARK: replace deinit
    
    /**
     Replace the implementation of object's deinit method by the closure.
     
     # Example
     ```
     class MyObject: NSObject {
     }
     var token: HookToken?
     autoreleasepool {
     let object = MyObject()
     token = try! hookDeallocInstead(object: object, closure: { original in
     print("before release")
     original()
     print("after release")
     })
     }
     token?.cancelHook() // cancel hook
     ```
     - parameter object: The object you want to hook on. It has to be inherited from NSObject.
     - parameter closure: The hook closure.
     
     **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     
     - parameter original: The original dealloc method.
     
     **WARNING**: Have to call original to avoid memory leak.
     
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    public func hookDeallocInstead(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> HookToken {
        try swiftHookSerialQueue.sync {
            try HookToken(for: object, selector: deallocSelector, mode: .instead, hookClosure: closure as AnyObject)._apply()
        }
    }
}
