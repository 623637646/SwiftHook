//
//  HookAllInstancesOC.swift
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
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
         NSLog(@"hooked");
     }];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        return try self.sh_hookBefore(selector: selector, closure: closure as Any)
    }
    
    // after
    /**
     Execute the closure after the execution of object's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
         NSLog(@"hooked");
     }];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        return try self.sh_hookAfter(selector: selector, closure: closure as Any)
    }
    
    // MARK: - self and selector closure
    
    // before
    /**
     Execute the closure with the object and the selector before the execution of object's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(NSObject * _Nonnull obj, SEL _Nonnull sel) {
         NSLog(@"hooked");
     }];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookBefore(selector: Selector, closureObjSel: @escaping @convention(block) (_ object: NSObject, _ selector: Selector) -> Void) throws -> HookToken {
        return try self.sh_hookBefore(selector: selector, closure: closureObjSel as Any)
    }
    
    // after
    /**
     Execute the closure with the object and the selector after the execution of object's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(NSObject * _Nonnull obj, SEL _Nonnull sel) {
         NSLog(@"hooked");
     }];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookAfter(selector: Selector, closureObjSel: @escaping @convention(block) (_ object: NSObject, _ selector: Selector) -> Void) throws -> HookToken {
        return try self.sh_hookAfter(selector: selector, closure: closureObjSel as Any)
    }
    
    // MARK: - custom closure
    
    // before
    /**
     Execute the closure with all parameters before the execution of object's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookBeforeSelector:@selector(sumWithNumber1:number2:) closure:^(MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2){
         NSLog(@"hooked");
     } error:NULL];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be YOUR CLASS or NSObject.
         2. The second parameter has to be SEL.
         3. The rest parameters are the same as the method's.
         4. The return type has to be Void.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookBefore(selector: Selector, closure: Any) throws -> HookToken {
        do {
            return try hookBefore(targetClass: self, selector: selector, closure: closure)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
    // after
    /**
     Execute the closure with all parameters after the execution of object's method.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookAfterSelector:@selector(sumWithNumber1:number2:) closure:^(MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2){
         NSLog(@"hooked");
     } error:NULL];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be YOUR CLASS or NSObject.
         2. The second parameter has to be SEL.
         3. The rest parameters are the same as the method's.
         4. The return type has to be Void.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookAfter(selector: Selector, closure: Any) throws -> HookToken {
        do {
            return try hookAfter(targetClass: self, selector: selector, closure: closure)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
    // instead
    /**
     Replace the implementation of object's method by the closure.
     
     # For example this is your class
     ```
     @interface MyObject : NSObject
     @end
     @implementation MyObject
     -(NSInteger)sumWithNumber1:(NSInteger)number1 number2:(NSInteger)number2 {
         return number1 + number2;
     }
     @end
     ```
     # Example to use the API
     ```
     HookToken *token = [MyObject sh_hookInsteadWithSelector:@selector(sumWithNumber1:number2:) closure:^NSInteger(NSInteger(^original)(MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2), MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
         // You may call the original method with some different parameters. You can even not call the original method.
         return original(obj, sel, number1, number2);
     } error:NULL];
     [[[MyObject alloc] init] sumWithNumber1:1 number2:2];
     [token revert];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. The following is a description of the closure
         1. The first parameter has to be a closure (block). This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
         2. The second parameter has to be YOUR CLASS or NSObject.
         3. The third parameter has to be SEL.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookInstead(selector: Selector, closure: Any) throws -> HookToken {
        do {
            return try hookInstead(targetClass: self, selector: selector, closure: closure)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
    // MARK: before deinit
    /**
     Execute the closure before the object dealloc.
     
     # Example
     ```
     HookToken *token = [MyObject sh_hookDeallocBeforeAndReturnError:NULL closure:^{
         NSLog(@"hooked");
     }];
     @autoreleasepool {
         MyObject *obj = [[MyObject alloc] init];
     }
     [token revert];
     ```
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        do {
            return try hookDeallocBefore(targetClass: self, closure: closure)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
    /**
     Execute the closure with the object before the object dealloc.
     
     # Example
     ```
     HookToken *token = [MyObject sh_hookDeallocBeforeAndReturnError:NULL closureObj:^(NSObject * _Nonnull obj) {
         NSLog(@"hooked");
     }];
     @autoreleasepool {
         MyObject *obj = [[MyObject alloc] init];
     }
     [token revert];
     ```
     - parameter closureObj: The hook closure.
     
       **WARNING**: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released. Otherwise it crashs on:
         1. `malloc: *** error for object: pointer being freed was not allocated`
         2. `Cannot form weak reference to instance of class xxx. It is possible that this object was over-released, or is in the process of deallocation.`
         3. `EXC_BAD_ACCESS`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookDeallocBefore(closureObj: @escaping @convention(block) (_ object: NSObject) -> Void) throws -> HookToken {
        do {
            return try hookDeallocBefore(targetClass: self, closure: closureObj)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
    // MARK: after deinit
    /**
     Execute the closure after the object dealloc.
     
     # Example
     ```
     HookToken *token = [MyObject sh_hookDeallocAfterAndReturnError:NULL closure:^{
         NSLog(@"hooked");
     }];
     @autoreleasepool {
         MyObject *obj = [[MyObject alloc] init];
     }
     [token revert];
     ```
     - parameter closure: The hook closure.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        do {
            return try hookDeallocAfter(targetClass: self, closure: closure)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
    // MARK: replace deinit
    /**
     Replace the implementation of object's dealloc method by the closure.
     
     # Example
     ```
     HookToken *token = [MyObject sh_hookDeallocInsteadAndReturnError:NULL closure:^(void (^ _Nonnull original)(void)) {
         NSLog(@"before release");
         original();
         NSLog(@"after release");
     }];
     @autoreleasepool {
         MyObject *obj = [[MyObject alloc] init];
     }
     [token revert];
     ```
     - parameter closure: The hook closure.
 
         **WARNING**: Have to call original to avoid memory leak.
     
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    @objc class func sh_hookDeallocInstead(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> HookToken {
        do {
            return try hookDeallocInstead(targetClass: self, closure: closure)
        } catch {
            guard let swiftHookError = error as? SwiftHookError else {
                throw error
            }
            throw swiftHookError.getNSError
        }
    }
    
}
