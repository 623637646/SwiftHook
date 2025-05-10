//
//  HookToken.swift
//  SwiftHook
//
//  Created by Florian Zand on 10.05.25.
//

import Foundation
import SwiftHookOCSources

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
        set { newValue ? apply() : revert() }
    }
    
    /// Applies the hook.
    @objc public func apply() {
        guard !isActive else {
            return
        }
        swiftHookSerialQueue.sync {
            if !hooksDealloc {
                try? internalApplyHook(token: self)
            } else if let object = hookObject {
                var delegate: HookDeallocAfterDelegate! = objc_getAssociatedObject(object, &associatedDelegateHandle) as? HookDeallocAfterDelegate
                if delegate == nil {
                    delegate = HookDeallocAfterDelegate()
                    objc_setAssociatedObject(object, &associatedDelegateHandle, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
                deallocAfterDelegate = delegate
                deallocAfterDelegate?.hookClosures.append(hookClosure)
            }
        }
    }
    
    /// Reverts the hook.
    @objc public func revert() {
        guard isActive else {
            return
        }
        swiftHookSerialQueue.sync {
            if hooksDealloc {
                deallocAfterDelegate?.hookClosures.removeAll(where: { $0 === self.hookClosure })
                deallocAfterDelegate = nil
            } else {
                _ = try? internalCancelHook(token: self)
            }
        }
    }
    
    init(object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) {
        self.hookObject = object
        self.targetClass = nil
        self.mode = mode
        self.selector = selector
        self.hookClosure = hookClosure
    }
    
    init(targetClass: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) {
        self.targetClass = targetClass
        self.mode = mode
        self.selector = selector
        self.hookClosure = hookClosure
    }
    
    init(deallocAfter object: AnyObject, hookClosure: AnyObject) {
        self.mode = .after
        self.selector = deallocSelector
        self.hookClosure = hookClosure
        self.targetClass = nil
        self.hooksDealloc = true
        self.hookObject = object
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
