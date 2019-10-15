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

func isSelectorAllowedForSingleInstance(obj: NSObject, selector: Selector, error: inout Error?) -> Bool {
    guard !blacklist.contains(selector) else {
        error? = getError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
        return false
    }
    let theClass = type(of: obj)
    guard theClass.instancesRespond(to: selector) else {
        error? = getError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
        return false
    }
    return true
}

func isSelectorAllowedForAllInstances(theClass: NSObject.Type, selector: Selector, error: inout Error?) -> Bool {
    guard !blacklist.contains(selector) else {
        error? = getError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
        return false
    }
    guard theClass.instancesRespond(to: selector) else {
        error? = getError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
        return false
    }
    return true
}

func isSelectorAllowedForClass(theClass: NSObject.Type, selector: Selector, error: inout Error?) -> Bool {
    guard !blacklist.contains(selector) else {
        error? = getError(code: .selectorBlacklisted, description: "Selector \(selector) is blacklisted.")
        return false
    }
    guard theClass.responds(to: selector) else {
        error? = getError(code: .doesNotRespondToSelector, description: "Unable to find selector \(selector) of \(theClass)")
        return false
    }
    return true
}
