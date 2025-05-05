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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
         NSLog(@"hooked");
     }];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookBefore(NSSelectorFromString(selector), closure: closure)
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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closure:^{
         NSLog(@"hooked");
     }];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closure as Any)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try hookAfter(NSSelectorFromString(selector), closure: closure as Any)
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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookBeforeSelector:@selector(sumWithNumber1:number2:) closure:^(MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
     } error:NULL];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain. The following is a description of the closure
         1. The first parameter has to be YOUR CLASS or NSObject.
         2. The second parameter has to be SEL.
         3. The rest parameters are the same as the method's.
         4. The return type has to be Void.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookAfterSelector:@selector(sumWithNumber1:number2:) closure:^(MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
     } error:NULL];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain. The following is a description of the closure
         1. The first parameter has to be YOUR CLASS or NSObject.
         2. The second parameter has to be SEL.
         3. The rest parameters are the same as the method's.
         4. The return type has to be Void.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookInsteadWithSelector:@selector(sumWithNumber1:number2:) closure:^NSInteger(NSInteger(^original)(MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2), MyObject * _Nonnull obj, SEL _Nonnull sel, NSInteger number1, NSInteger number2) {
         NSLog(@"hooked");
         // You may call the original method with some different parameters. You can even not call the original method.
         return original(obj, sel, number1, number2);
     } error:NULL];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain. The following is a description of the closure
         1. The first parameter has to be a closure (block). This closure means original method. The closure's parameters and return type are the same as the original method's (The parameters contain Object and Selector at the beginning)..
         2. The second parameter has to be YOUR CLASS or NSObject.
         3. The third parameter has to be SEL.
         4. The rest parameters are the same as the method's.
         5. The return type has to be the same as the original method's.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookInstead(_ selector: Selector, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookInstead(selector, closure: closure)
    }
    
    @discardableResult
    func hookInstead(_ selector: String, closure: Any) throws -> HookToken {
        try ObjectHook(self).hookInstead(selector, closure: closure)
    }
}

public extension NSObjectProtocol where Self: NSObject {
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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookBeforeSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(NSObject * _Nonnull obj, SEL _Nonnull sel) {
         NSLog(@"hooked");
     }];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookBefore(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        let typedClosure: @convention(block) (NSObject, Selector) -> Void = { obj, sel in
            guard let typedObj = obj as? Self else {
                assertionFailure("Failed to cast \(obj) to expected type \(Self.self)")
                return
            }
            closure(typedObj, sel)
        }
        return try hookBefore(selector, closureObjSel: typedClosure)
    }
    
    @discardableResult
    func hookBefore(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
       try hookBefore(NSSelectorFromString(selector), closure: closure)
    }
    
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
     MyObject *obj = [[MyObject alloc] init];
     OCHookToken *token = [obj hookAfterSelector:@selector(sumWithNumber1:number2:) error:NULL closureObjSel:^(NSObject * _Nonnull obj, SEL _Nonnull sel) {
         NSLog(@"hooked");
     }];
     [obj sumWithNumber1:1 number2:2];
     [token cancelHook];
     ```
     - parameter selector: The method you want to hook on.
     - parameter closureObjSel: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookAfter(_ selector: Selector, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
        let typedClosure: @convention(block) (NSObject, Selector) -> Void = { obj, sel in
            guard let typedObj = obj as? Self else {
                assertionFailure("Failed to cast \(obj) to expected type \(Self.self)")
                return
            }
            closure(typedObj, sel)
        }
        return try hookAfter(selector, closureObjSel: typedClosure)
    }
    
    @discardableResult
    func hookAfter(_ selector: String, closure: @escaping (Self, Selector) -> Void) throws -> HookToken {
       try hookAfter(NSSelectorFromString(selector), closure: closure)
    }
}

fileprivate extension NSObject {
    @discardableResult
    func hookBefore(_ selector: Selector, closureObjSel: @escaping @convention(block) (_ object: NSObject, _ selector: Selector) -> Void) throws -> HookToken {
        try hookBefore(selector, closure: closureObjSel as Any)
    }

    @discardableResult
    func hookAfter(_ selector: Selector, closureObjSel: @escaping @convention(block) (_ object: NSObject, _ selector: Selector) -> Void) throws -> HookToken {
        try hookAfter(selector, closure: closureObjSel as Any)
    }
}

public extension NSObject {
    // MARK: before deinit
    
    /**
     Execute the closure before the object dealloc.
     
     # Example
     ```
     OCHookToken *token = nil;
     @autoreleasepool {
         NSObject *obj = [[NSObject alloc] init];
         token = [obj hookDeallocBeforeAndReturnError:NULL closure:^{
             NSLog(@"hooked");
         }];
     }
     [token cancelHook];
     ```
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocBefore(closure: closure)
    }

    /**
     Execute the closure with the object before the object dealloc.
     
     # Example
     ```
     OCHookToken *token = nil;
     @autoreleasepool {
         NSObject *obj = [[NSObject alloc] init];
         token = [obj hookDeallocBeforeAndReturnError:NULL closureObj:^(NSObject * _Nonnull obj) {
             NSLog(@"hooked");
         }];
     }
     [token cancelHook];
     ```
     - parameter closureObj: The hook closure.
     
       **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     
       **WARNING**: In the closure, do not assign the object to anywhere outside the closure. Do not keep the reference of the object. Because the object is going to be released. Otherwise it crashs on:
         1. `malloc: *** error for object: pointer being freed was not allocated`
         2. `Cannot form weak reference to instance of class xxx. It is possible that this object was over-released, or is in the process of deallocation.`
         3. `EXC_BAD_ACCESS`.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocBefore(closureObj: @escaping @convention(block) (_ object: NSObject) -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocBefore(closure: closureObj)
    }

    // MARK: after deinit
    
    /**
     Execute the closure after the object dealloc.
     
     # Example
     ```
     OCHookToken *token = nil;
     @autoreleasepool {
         NSObject *obj = [[NSObject alloc] init];
         token = [obj hookDeallocAfterAndReturnError:NULL closure:^{
             NSLog(@"hooked");
         }];
     }
     [token cancelHook];
     ```
     - parameter closure: The hook closure. **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocAfter(closure: closure)
    }

    // MARK: replace deinit

    /**
     Replace the implementation of object's dealloc method by the closure.
     
     # Example
     ```
     OCHookToken *token = nil;
     @autoreleasepool {
         NSObject *obj = [[NSObject alloc] init];
         token = [obj hookDeallocInsteadAndReturnError:NULL closure:^(void (^ _Nonnull original)(void)) {
             NSLog(@"before release");
             original();
             NSLog(@"after release");
         }];
     }
     [token cancelHook];
     ```
     - parameter closure: The hook closure.
     
         **WARNING**: The object will retain the closure. So make sure that the closure doesn't retain the object in turn to avoid memory leak because of cycle retain.
 
         **WARNING**: Have to call original to avoid memory leak.
     
     - returns: The token of this hook behavior. You may cancel this hook through this token.
     */
    @discardableResult
    func hookDeallocInstead(closure: @escaping @convention(block) (_ original: () -> Void) -> Void) throws -> HookToken {
        try ObjectHook(self).hookDeallocInstead(closure: closure)
    }
}

/*
 @discardableResult
 func hookBefore<Block>(_ selector: Selector, signature: Block.Type, closure: Block) throws -> HookToken {
     try SwiftHook.hookBefore(selector, object: self, closure: closure)
 }
 */
