//
//  SwiftHookOCBridge.swift
//  SwiftHook
//
//  Created by Yanni Wang on 22/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit

@objcMembers public class OCToken: NSObject {
    let token: Token
    init(token: Token) {
        self.token = token
    }
    public func cancelHook() {
        token.cancelHook()
    }
}

@objcMembers public class SwiftHookOCBridge: NSObject {
    
    // MARK: Hook single instance
    
    @discardableResult
    class public func ocHookBefore(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookBefore(object: object, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookBefore(object: AnyObject, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookBefore(object: object, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookAfter(object: AnyObject, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookAfter(object: object, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookAfter(object: AnyObject, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookAfter(object: object, selector: selector, closure: closure))
    }
    
    @discardableResult
    class public func ocHookInstead(object: AnyObject, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookInstead(object: object, selector: selector, closure: closure))
    }

    // MARK: Hook all instances

    @discardableResult
    class public func ocHookBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookBefore(targetClass: targetClass, selector: selector, closure: closure))
    }
    
    @discardableResult
    class public func ocHookBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookBefore(targetClass: targetClass, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookAfter(targetClass: targetClass, selector: selector, closure: closure))
    }
    
    @discardableResult
    class public func ocHookAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookAfter(targetClass: targetClass, selector: selector, closure: closure))
    }
    
    @discardableResult
    class public func ocHookInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookInstead(targetClass: targetClass, selector: selector, closure: closure))
    }

    // MARK: Hook class methods

    @discardableResult
    class public func ocHookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookClassMethodBefore(targetClass: targetClass, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookClassMethodBefore(targetClass: AnyClass, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookClassMethodBefore(targetClass: targetClass, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookClassMethodAfter(targetClass: targetClass, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookClassMethodAfter(targetClass: AnyClass, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookClassMethodAfter(targetClass: targetClass, selector: selector, closure: closure))
    }

    @discardableResult
    class public func ocHookClassMethodInstead(targetClass: AnyClass, selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookClassMethodInstead(targetClass: targetClass, selector: selector, closure: closure))
    }

    // MARK: Hook single dealloc

    @discardableResult
    class public func ocHookDeallocBefore(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocBefore(object: object, closure: closure))
    }

    @discardableResult
    class public func ocHookDeallocAfter(object: NSObject, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocAfter(object: object, closure: closure))
    }

    /**
     This method can hook dealloc in after WITHOUT runtime. Just add a object (tail) to observe dealloc.
     */
    @discardableResult
    class public func ocHookDeallocAfterByTail(object: AnyObject, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocAfterByTail(object: object, closure: closure))
    }

    /**
     Have to call original to avoid memory leak.
     eg:
     OCToken(token: try hookDeallocInstead(object: object, closure: { original in
     original()
     } as @convention(block) (() -> Void) -> Void)
     */
    @discardableResult
    class public func ocHookDeallocInstead(object: NSObject, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocInstead(object: object, closure: closure))
    }

    // MARK: Hook all instances dealloc

    @discardableResult
    class public func ocHookDeallocBefore(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocBefore(targetClass: targetClass, closure: closure))
    }

    @discardableResult
    class public func ocHookDeallocAfter(targetClass: NSObject.Type, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocAfter(targetClass: targetClass, closure: closure))
    }

    /**
     Have to call original to avoid memory leak.
     eg:
     OCToken(token: try hookDeallocInstead(targetClass: targetClass, closure: { original in
     original()
     } as @convention(block) (() -> Void) -> Void)
     */
    @discardableResult
    class public func ocHookDeallocInstead(targetClass: NSObject.Type, closure: @escaping @convention(block) (() -> Void) -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocInstead(targetClass: targetClass, closure: closure))
    }
}
