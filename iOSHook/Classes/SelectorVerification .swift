//
//  SelectorVerification .swift
//  iOSHook
//
//  Created by Yanni Wang on 15/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

private let blacklist = [NSSelectorFromString("retain"),
                         NSSelectorFromString("release"),
                         NSSelectorFromString("autorelease"),
                         NSSelectorFromString("forwardInvocation:"),
                         NSSelectorFromString("dealloc")]

func isSelectorAllowedForSingleInstance(obj: NSObject, selector: Selector) throws -> Bool {
    guard !blacklist.contains(selector) else {
        throw iOSHookError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
    }
    let theClass = type(of: obj)
    guard theClass.instancesRespond(to: selector) else {
        throw iOSHookError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
    }
    return true
}

func isSelectorAllowedForAllInstances(theClass: NSObject.Type, selector: Selector) throws -> Bool {
    guard !blacklist.contains(selector) else {
        throw iOSHookError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
    }
    guard theClass.instancesRespond(to: selector) else {
        throw iOSHookError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
    }
    return true
}

func isSelectorAllowedForClass(theClass: NSObject.Type, selector: Selector) throws -> Bool {
    guard !blacklist.contains(selector) else {
        throw iOSHookError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
    }
    guard theClass.responds(to: selector) else {
        throw iOSHookError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
    }
    return true
}
