//
//  SwiftHookOCBridge.swift
//  SwiftHook
//
//  Created by Yanni Wang on 22/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit

// MARK: - Token

@objcMembers public class OCToken: NSObject {
    private let token: Token
    fileprivate init(token: Token) {
        self.token = token
    }
    public func cancelHook() {
        token.cancelHook()
    }
}

// TODO: 转换NSError

public extension NSObject {
    
    // MARK: - Hook specified instance
    
    @discardableResult
    @objc func sh_hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookBefore(object: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc func sh_hookBefore(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookBefore(object: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc func sh_hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookAfter(object: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc func sh_hookAfter(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookAfter(object: self, selector: selector, closure: closure))
    }
    
    @discardableResult
    @objc func sh_hookInstead(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookInstead(object: self, selector: selector, closure: closure))
    }

    // MARK: - Hook all instances

    @discardableResult
    @objc class func sh_hookBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookBefore(targetClass: self, selector: selector, closure: closure))
    }
    
    @discardableResult
    @objc class func sh_hookBefore(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookBefore(targetClass: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc class func sh_hookAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookAfter(targetClass: self, selector: selector, closure: closure))
    }
    
    @discardableResult
    @objc class func sh_hookAfter(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookAfter(targetClass: self, selector: selector, closure: closure))
    }
    
    @discardableResult
    @objc class func sh_hookInstead(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookInstead(targetClass: self, selector: selector, closure: closure))
    }

    // MARK: - Hook class methods

    @discardableResult
    @objc class func sh_hookClassMethodBefore(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookClassMethodBefore(targetClass: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc class func sh_hookClassMethodBefore(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookClassMethodBefore(targetClass: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc class func sh_hookClassMethodAfter(selector: Selector, closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookClassMethodAfter(targetClass: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc class func sh_hookClassMethodAfter(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookClassMethodAfter(targetClass: self, selector: selector, closure: closure))
    }

    @discardableResult
    @objc class func sh_hookClassMethodInstead(selector: Selector, closure: Any) throws -> OCToken {
        OCToken(token: try hookClassMethodInstead(targetClass: self, selector: selector, closure: closure))
    }

    // MARK: - Hook specified instance dealloc

    @discardableResult
    @objc func sh_hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocBefore(object: self, closure: closure))
    }

    @discardableResult
    @objc func sh_hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocAfter(object: self, closure: closure))
    }
    
    @discardableResult
    @objc func sh_hookDeallocAfterByTail(closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocAfterByTail(object: self, closure: closure))
    }
    
    @discardableResult
    @objc func sh_hookDeallocInstead(closure: @escaping @convention(block) (() -> Void) -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocInstead(object: self, closure: closure))
    }

    // MARK: - Hook all instances dealloc

    @discardableResult
    @objc class func sh_hookDeallocBefore(closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocBefore(targetClass: self, closure: closure))
    }

    @discardableResult
    @objc class func sh_hookDeallocAfter(closure: @escaping @convention(block) () -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocAfter(targetClass: self, closure: closure))
    }
    
    @discardableResult
    @objc class func sh_hookDeallocInstead(closure: @escaping @convention(block) (() -> Void) -> Void) throws -> OCToken {
        OCToken(token: try hookDeallocInstead(targetClass: self, closure: closure))
    }
}
