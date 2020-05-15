//
//  HookToken.swift
//  SwiftHook
//
//  Created by Yanni Wang on 12/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

public struct HookToken {
    
    weak var hookContext: HookContext?
    weak var hookClosure: AnyObject?
    let mode: HookMode
    
    init(hookContext: HookContext, hookClosure: AnyObject, mode: HookMode) {
        self.hookContext = hookContext
        self.hookClosure = hookClosure
        self.mode = mode
    }
    
    /**
    # Cancel hook.
    Try to change the Method's IMP from hooked to original and released context.
    But it's dangerous when the current IMP is not previous hooked IMP. In this case. cancelHook() still works fine but the context will not be released.
    
    - returns:
    Return true if the context will be released. Return false if the context will not be released. Returen nil means some issues like token already canceled.
    */
    @discardableResult
    public func cancelHook() -> Bool? {
        return HookManager.shared.cancelHook(token: self)
    }
}
