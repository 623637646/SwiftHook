//
//  HookToken.swift
//  iOSHook
//
//  Created by Yanni Wang on 27/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

public class HookToken {
    enum Mode {
        case before
        case after
        case instead
    }
    
    let `class`: AnyClass
    let selector : Selector
    let mode: Mode
    let hookBlock: AnyObject
    
    private init(class: AnyClass, selector: Selector, mode: Mode, hookBlock: AnyObject) {
        self.`class` = `class`
        self.selector = selector
        self.mode = mode
        self.hookBlock = hookBlock
    }
    
    class func hook(class: AnyClass, selector: Selector, mode: Mode, hookBlock: AnyObject) -> HookToken{
        let hookToken = HookToken.init(class: `class`, selector: selector, mode: mode, hookBlock: hookBlock)
        return hookToken
    }
}
