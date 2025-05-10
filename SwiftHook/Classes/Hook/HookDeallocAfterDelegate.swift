//
//  HookDeallocAfterDelegate.swift
//  SwiftHook
//
//  Created by Yanni Wang on 17/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

func hookDeallocAfterByDelegate(object: AnyObject, closure: AnyObject) -> HookToken {
    let token = HookToken(deallocAfter: object, hookClosure: closure)
    _ = token.apply()
    return token
}
