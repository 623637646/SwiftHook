//
//  HookToken.swift
//  SwiftHook
//
//  Created by Yanni Wang on 12/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

public protocol Token {
    func cancelHook()
}

struct HookToken: Token {
    
    weak var hookContext: HookContext?
    weak var hookClosure: AnyObject?
    let mode: HookMode
    
    weak var hookObject: AnyObject? // This is only for single instance hook
    
    init(hookContext: HookContext, hookClosure: AnyObject, mode: HookMode) {
        self.hookContext = hookContext
        self.hookClosure = hookClosure
        self.mode = mode
    }
    
    public func cancelHook() {
        swiftHookSerialQueue.sync {
            _ = internalCancelHook(token: self)
        }
    }
}
