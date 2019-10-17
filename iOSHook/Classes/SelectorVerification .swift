//
//  SelectorVerification .swift
//  iOSHook
//
//  Created by Yanni Wang on 15/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

private let blacklist = [ObjCSelector.retain,
                         ObjCSelector.release,
                         ObjCSelector.autorelease,
                         ObjCSelector.forwardInvocation,
                         ObjCSelector.dealloc]

func isSelectorAllowedForInstances(theClass: AnyClass, selector: Selector) throws -> Bool {
    assert(!class_isMetaClass(theClass))
    guard !blacklist.contains(selector) else {
        throw iOSHookError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
    }
    guard theClass.instancesRespond(to: selector) else {
        throw iOSHookError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
    }
    return true
}

func isSelectorAllowedForClass(theClass: AnyClass, selector: Selector) throws -> Bool {
    assert(!class_isMetaClass(theClass))
    guard !blacklist.contains(selector) else {
        throw iOSHookError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
    }
    guard theClass.responds(to: selector) else {
        throw iOSHookError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
    }
    return true
}
