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
        do {
            for _ in 0...10000000 {
                try TestObject.hook(selector: #selector(TestObject.simple),
                                                signature: (nil, nil),
                                                block: { (original, args: Void) -> Void in
                                                    return original(args)
                            })
                //            TestObject().simple()
            }
        } catch {
            print("%@", error)
        }
    }
}
