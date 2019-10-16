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
    
    func testSingleInstance() {
        let obj = TestObject()
        var triggered = false
        try! obj.hookSelfAtBefore(selector: #selector(TestObject.simpleMethod), onlyOnce: false, block: {(obj, _: Void) in
            triggered = true
        })
        XCTAssert(triggered == false)
        obj.simpleMethod()
        //        XCTAssert(triggered == true)
    }
    
    func testAllInstance() {
        var triggered = false
        try! TestObject.hookAllInstancesAtBefore(selector: #selector(TestObject.simpleMethod), onlyOnce: false, block: {(obj, _: Void) in
            triggered = true
        })
        XCTAssert(triggered == false)
        TestObject().simpleMethod()
        //            XCTAssert(triggered == true)
    }
    
    func testClass() {
        var triggered = false
        try! TestObject.hookClassMethodAtBefore(selector: #selector(TestObject.classSimpleMethod), onlyOnce: false, block: {(_: Void) in
            triggered = true
        })
        XCTAssert(triggered == false)
        TestObject().simpleMethod()
        //            XCTAssert(triggered == true)
    }
    
}
