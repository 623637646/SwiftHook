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
            typealias TargetBlock = () -> Void
            typealias HookBlock = @convention(block) (TargetBlock) -> Void

            try TestObject.hook(selector: #selector(TestObject.simple), block: { (original) -> Void in
                return original()
            } as HookBlock)
            TestObject().simple()
        } catch {
            print("%@", error)
        }
    }
}
