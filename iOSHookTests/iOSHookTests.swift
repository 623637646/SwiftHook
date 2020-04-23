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
        print("\(self) , \(#function)")
    }
}

class InstanceBeforeTests: XCTestCase {
    func testHook() {
        do {
            try TestObject.hook(selector: #selector(TestObject.simple),
                                signature: (nil, nil),
                                block: { (original, args: Void) -> Void in
                                    return original(args)
            })
            TestObject().simple()
        } catch {
            print("%@", error)
        }
    }
}
