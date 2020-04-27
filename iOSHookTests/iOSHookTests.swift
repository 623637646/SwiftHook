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
        try! TestObject.hookBefore(selector: #selector(TestObject.noArgsNoReturnFunc), block: {
            
        })
    }
}
