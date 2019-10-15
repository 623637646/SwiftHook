//
//  Error.swift
//  iOSHook
//
//  Created by Yanni Wang on 15/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

// domain
public let domain = "com.iOSHook"
public enum ErrorCode: Int {
    case internalError = 0
    case selectorBlacklisted
    case doesNotRespondToSelector
}

func getError(code: ErrorCode, description: String) -> NSError {
    return NSError.init(domain: domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: description])
}
