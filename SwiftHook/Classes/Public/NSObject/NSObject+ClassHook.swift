//
//  HookClassMethodsOC.swift
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
     Execute the closure before the execution of class's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
         NSLog(@"hooked");
     }];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassMethodBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookClassMethodBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookClassMethodBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookClassMethodBefore(NSSelectorFromString(selector), closure: closure as Any)
    }
    
    // after
    /**
     Execute the closure after the execution of class's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
         NSLog(@"hooked");
     }];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassMethodAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookClassMethodAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    class func hookClassMethodAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookClassMethodAfter(NSSelectorFromString(selector), closure: closure as Any)
    }
                
    // MARK: - custom closure
    
    // before
    /**
     Execute the closure with all parameters before the execution of class's method.

     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodBeforeSelector:@selector(sumWithNumber1:number2:) closure:^(NSObject *obj, SEL sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
     } error:NULL];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be NSObject.
         2. The second parameter has to be SEL.
         3. The rest parameters are the same as the method's.
         4. The return type has to be Void.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassMethodBefore(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    @discardableResult
    class func hookClassMethodBefore(_ selector: String, closure: Any) throws -> HookToken {
        try ClassHook(self).hookBefore(selector, closure: closure)
    }
    
    // after
    /**
     Execute the closure with all parameters after the execution of class's method.

     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodAfterSelector:@selector(sumWithNumber1:number2:) closure:^(NSObject *obj, SEL sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
     } error:NULL];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be NSObject.
         2. The second parameter has to be SEL.
         3. The rest parameters are the same as the method's.
         4. The return type has to be Void.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassMethodAfter(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    @discardableResult
    class func hookClassMethodAfter(_ selector: String, closure: Any) throws -> HookToken {
        try ClassHook(self).hookAfter(selector, closure: closure)
    }
    
    // instead
    /**
     Replace the implementation of class's method by the closure.

     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodInsteadWithSelector:@selector(sumWithNumber1:number2:) closure:^NSInteger(NSInteger(^original)(NSObject *obj, SEL sel, NSInteger number1, NSInteger number2), NSObject *obj, SEL sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
         return original(obj, sel, number1, number2);
     } error:NULL];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be a closure (block). This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
         2. The second parameter has to be NSObject.
         3. The third parameter has to be SEL.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    class func hookClassMethodInstead(_ selector: Selector, closure: Any) throws -> HookToken {
        try ClassHook(self).hookInstead(selector, closure: closure)
    }
    
    @discardableResult
    class func hookClassMethodInstead(_ selector: String, closure: Any) throws -> HookToken {
        try ClassHook(self).hookInstead(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
    /**
     Execute the closure with the object and the selector before the execution of class's method.

     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(Class  _Nonnull __unsafe_unretained obj, SEL _Nonnull sel) {
         NSLog(@"hooked");
     }];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookClassMethodBefore(_ selector: Selector, closureObjSel: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        let typedClosure: @convention(block) (NSObject, Selector) -> Void = { obj, sel in
            guard let obj = obj as? Self.Type else { fatalError() }
            closureObjSel(obj, sel)
        }
        return try hookClassMethodBefore(selector, closure: typedClosure as Any)
    }
    
    @discardableResult
    static func hookClassMethodBefore(_ selector: String, closureObjSel: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        try hookClassMethodBefore(NSSelectorFromString(selector), closureObjSel: closureObjSel)
    }
    
    /**
     Execute the closure with the object and the selector after the execution of class's method.

     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     +(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     OCHookToken *token = [MyObject sh_hookClassMethodAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(Class  _Nonnull __unsafe_unretained obj, SEL _Nonnull sel) {
         NSLog(@"hooked");
     }];
     [MyObject sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    static func hookClassMethodAfter(_ selector: Selector, closureObjSel: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        let typedClosure: @convention(block) (NSObject, Selector) -> Void = { obj, sel in
            guard let obj = obj as? Self.Type else { fatalError() }
            closureObjSel(obj, sel)
        }
        return try hookClassMethodAfter(selector, closure: typedClosure as Any)
    }
    
    @discardableResult
    static func hookClassMethodAfter(_ selector: String, closureObjSel: @escaping (_ class: Self.Type, _ selector: Selector) -> Void) throws -> HookToken {
        try hookClassMethodAfter(NSSelectorFromString(selector), closureObjSel: closureObjSel)
    }
}

/*
 class func hookClassMethodBefore(_ selector: Selector, closureObjSel: @escaping (_ class: AnyClass, _ selector: Selector) -> Void) throws -> HookToken {
     let closureObjSel = { obj, sel in
         guard let obj = obj as? AnyClass else { fatalError() }
         closureObjSel(obj, sel)
     } as @convention(block) (AnyObject, Selector) -> Void
     return try hookClassMethodBefore(selector, closure: closureObjSel as Any)
 }
 
 @discardableResult
 class func hookClassMethodAfter(_ selector: Selector, closureObjSel: @escaping (_ class: AnyClass, _ selector: Selector) -> Void) throws -> HookToken {
     let closureObjSel = { obj, sel in
         guard let obj = obj as? AnyClass else { fatalError() }
         closureObjSel(obj, sel)
     } as @convention(block) (AnyObject, Selector) -> Void
     return try hookClassMethodAfter(selector, closure: closureObjSel as Any)
 }
 */
