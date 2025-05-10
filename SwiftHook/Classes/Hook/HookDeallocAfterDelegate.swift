//
//  HookDeallocAfterDelegate.swift
//  SwiftHook
//
//  Created by Yanni Wang on 17/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private class HookDeallocAfterDelegate {
    
    var hookClosures = [AnyObject]()
    
    deinit {
        for item in hookClosures.reversed() {
            unsafeBitCast(item, to: (@convention(block) () -> Void).self)()
        }
    }
}

private struct HookDeallocAfterToken: Token {
    
    weak var delegate: HookDeallocAfterDelegate?
    weak var closure: AnyObject?
    
    init(delegate: HookDeallocAfterDelegate, closure: AnyObject) {
        self.delegate = delegate
        self.closure = closure
    }
    
    func cancelHook() {
        delegate?.hookClosures.removeAll(where: {(closure) -> Bool in
            return closure === self.closure
        })
    }
}

func hookDeallocAfterByDelegate(object: AnyObject, closure: AnyObject) -> Token {
    let delegate = getAssociatedValue("associatedDelegateHandle", object: object, initialValue: HookDeallocAfterDelegate())
    delegate.hookClosures.append(closure)
    return HookDeallocAfterToken.init(delegate: delegate, closure: closure)
}
