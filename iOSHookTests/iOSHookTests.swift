//
//  InstanceBeforeTests.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 14/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import XCTest
import iOSHook

class InstanceBeforeTests: XCTestCase {
    
    func testHook() {
        try! TestObject.hook(selector: #selector(TestObject.noArgsNoReturnFunc),
                             signature: (nil, nil),
                             block: { (original, args: Void) -> Void in
                                return original(args)
        })
    }
}
