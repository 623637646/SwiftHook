//
//  Constant.swift
//  iOSHook
//
//  Created by Yanni Wang on 17/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

enum ObjCSelector {
    static let retain = Selector((("retain")))
    static let release = Selector((("release")))
    static let autorelease = Selector((("autorelease")))
    static let forwardInvocation = Selector((("forwardInvocation:")))
    static let dealloc = Selector((("dealloc")))
}
