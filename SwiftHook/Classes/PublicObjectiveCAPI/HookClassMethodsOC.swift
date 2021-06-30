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
     OCToken *token = [MyObject sh_hookClassMethodBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
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
    @objc class func sh_hookClassMethodBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        return try self.sh_hookClassMethodBefore(selector: selector, closure: closure as Any)
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
     OCToken *token = [MyObject sh_hookClassMethodAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
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
    @objc class func sh_hookClassMethodAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        return try self.sh_hookClassMethodAfter(selector: selector, closure: closure as Any)
    }
    
    // MARK: - self and selector closure
    
    // before
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
     OCToken *token = [MyObject sh_hookClassMethodBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(Class  _Nonnull __unsafe_unretained obj, SEL _Nonnull sel) {
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
    @objc class func sh_hookClassMethodBefore(selector: Selector, closureObjSel: @escaping (_ class: AnyClass, _ selector: Selector) -> Void) throws -> OCToken {
        let closureObjSel = { obj, sel in
            guard let obj = obj as? AnyClass else { fatalError() }
            closureObjSel(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try self.sh_hookClassMethodBefore(selector: selector, closure: closureObjSel as Any)
    }
    
    // after
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
     OCToken *token = [MyObject sh_hookClassMethodAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(Class  _Nonnull __unsafe_unretained obj, SEL _Nonnull sel) {
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
    @objc class func sh_hookClassMethodAfter(selector: Selector, closureObjSel: @escaping (_ class: AnyClass, _ selector: Selector) -> Void) throws -> OCToken {
        let closureObjSel = { obj, sel in
            guard let obj = obj as? AnyClass else { fatalError() }
            closureObjSel(obj, sel)
        } as @convention(block) (AnyObject, Selector) -> Void
        return try self.sh_hookClassMethodAfter(selector: selector, closure: closureObjSel as Any)
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
     OCToken *token = [MyObject sh_hookClassMethodBeforeSelector:@selector(sumWithNumber1:number2:) closure:^(NSObject *obj, SEL sel, NSInteger number1, NSInteger number2) {
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
    @objc class func sh_hookClassMethodBefore(selector: Selector, closure: Any) throws -> OCToken {
        do {
            return OCToken(token: try hookClassMethodBefore(targetClass: self, selector: selector, closure: closure))
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
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
     OCToken *token = [MyObject sh_hookClassMethodAfterSelector:@selector(sumWithNumber1:number2:) closure:^(NSObject *obj, SEL sel, NSInteger number1, NSInteger number2) {
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
    @objc class func sh_hookClassMethodAfter(selector: Selector, closure: Any) throws -> OCToken {
        do {
            return OCToken(token: try hookClassMethodAfter(targetClass: self, selector: selector, closure: closure))
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
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
     OCToken *token = [MyObject sh_hookClassMethodInsteadWithSelector:@selector(sumWithNumber1:number2:) closure:^NSInteger(NSInteger(^original)(NSObject *obj, SEL sel, NSInteger number1, NSInteger number2), NSObject *obj, SEL sel, NSInteger number1, NSInteger number2) {
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
    @objc class func sh_hookClassMethodInstead(selector: Selector, closure: Any) throws -> OCToken {
        do {
            return OCToken(token: try hookClassMethodInstead(targetClass: self, selector: selector, closure: closure))
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
}
