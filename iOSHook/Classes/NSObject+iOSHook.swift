//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

public extension NSObject {
    @discardableResult
    class func hook(selector: Selector,
                    block: (_ original: (_ args: [Any?]) -> Any?, _ args: [Any?]) -> Any?) -> Token {
        return Token()
    }
}
