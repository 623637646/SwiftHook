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
    @objc dynamic func simple(int: Int, double: Double, string: String) {
        
    }
}

class InstanceBeforeTests: XCTestCase {
    func testHook() {
        do {
            try TestObject.hook(selector: #selector(TestObject.simple(int:double:string:))) { (original, args: (Int, Double, String)) -> Void in
                return original(args)
            }
            TestObject().simple(int: 111, double: 2.12, string: "fff")
        } catch {
            print("%@", error)
        }
    }
}
