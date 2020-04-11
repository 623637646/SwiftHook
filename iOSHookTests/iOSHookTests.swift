//
//  InstanceBeforeTests.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 14/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import XCTest
import iOSHook

class TestObject: NSObject {
    @objc dynamic func simple() {
        
    }
}

class InstanceBeforeTests: XCTestCase {
    func testHook() {
        try! TestObject.hook(selector: #selector(TestObject.simple)) { (original, args) -> Any? in
            return original(args)
        }
        TestObject().simple()
    }
}
