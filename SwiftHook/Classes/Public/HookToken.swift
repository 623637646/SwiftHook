//
//  HookToken.swift
//  SwiftHook
//
//  Created by Florian Zand on 10.05.25.
//

import Foundation

/// Represents a hook to a method.
@objcMembers
public class HookToken: NSObject {
    
    let hookClosure: AnyObject
    weak var hookObject: AnyObject? // This is only for specified instance hook
    let targetClass: AnyClass?
    var hooksDealloc = false
    weak var deallocAfterDelegate: HookDeallocAfterDelegate?
    weak var hookContext: HookContext?
    
    /// The hooking mode.
    @objc public let mode: HookMode
    
    /// The selector of the hook.
    @objc public let selector: Selector
    
    /// A Boolean value indicating whether the hook is active.
    @objc public var isActive: Bool {
        get { hookContext != nil || deallocAfterDelegate != nil }
        set { _ = newValue ? apply() : revert() }
    }
    
    /**
     Applies the hook.
     
     - Returns: `true` if the hook is successfully applied, otherwise `false`.
     */
    @discardableResult
    @objc public func apply() -> Bool {
        guard !isActive else {
            return true
        }
        return swiftHookSerialQueue.sync {
            if !hooksDealloc {
                try? internalApplyHook(token: self)
                return isActive
            } else if let object = hookObject {
                var delegate: HookDeallocAfterDelegate! = objc_getAssociatedObject(object, &associatedDelegateHandle) as? HookDeallocAfterDelegate
                if delegate == nil {
                    delegate = HookDeallocAfterDelegate()
                    objc_setAssociatedObject(object, &associatedDelegateHandle, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
                deallocAfterDelegate = delegate
                deallocAfterDelegate?.hookClosures.append(hookClosure)
                return true
            }
            return false
        }
    }
    
    /**
     Reverts the hook.
     
     - Returns: `true` if the hook is successfully reverted, otherwise `false`.
     */
    @discardableResult
    @objc public func revert() -> Bool {
        guard isActive else {
            return true
        }
        return swiftHookSerialQueue.sync {
            if hooksDealloc {
                deallocAfterDelegate?.hookClosures.removeAll(where: { $0 === self.hookClosure })
                deallocAfterDelegate = nil
                return true
            } else {
                _ = try? internalCancelHook(token: self)
                return !isActive
            }
        }
    }
    
    init(object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try swiftHookSerialQueue.sync {
            try parametersCheck(object: object, selector: deallocSelector, mode: .instead, closure: hookClosure)
        }
        self.hookObject = object
        self.targetClass = nil
        self.mode = mode
        self.selector = selector
        self.hookClosure = hookClosure
    }
    
    init(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try swiftHookSerialQueue.sync {
            try parametersCheck(targetClass: targetClass, selector: deallocSelector, mode: .instead, closure: hookClosure)
        }
        self.targetClass = targetClass
        self.mode = mode
        self.selector = selector
        self.hookClosure = hookClosure
    }
    
    init(deallocAfter object: AnyObject, hookClosure: AnyObject) {
        self.targetClass = nil
        self.hookObject = object
        self.mode = .after
        self.selector = deallocSelector
        self.hookClosure = hookClosure
        self.hooksDealloc = true
    }

    class HookDeallocAfterDelegate {
        var hookClosures = [AnyObject]()
        
        deinit {
            for item in hookClosures.reversed() {
                unsafeBitCast(item, to: (@convention(block) () -> Void).self)()
            }
        }
    }
}

private var associatedDelegateHandle: UInt8 = 0
