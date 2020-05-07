//
//  SwiftHookTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SwiftHookTests: XCTestCase {
    
    func testnoRespondSelector() {
        do {
            try TestObject.hookBefore(selector: #selector(NSArray.object(at:)), closure: {})
            XCTAssertTrue(false)
        } catch SwiftHookError.noRespondSelector(let targetClass, let selector) {
            XCTAssertTrue(targetClass == TestObject.self)
            XCTAssertEqual(selector, #selector(NSArray.object(at:)))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testMemory() {
//        while true {
//            autoreleasepool {
//                testHookBeforeNoArgsNoReturnFunc()
//                testHookBeforeSumFunc()
//            }
//        }
    }
    
    // MARK: Before
    
    func testHookBeforeNoArgsNoReturnFunc() {
        var called = false
        do {
            try TestObject.hookBefore(selector: #selector(TestObject.noArgsNoReturnFunc), closure: {
                called = true
            })
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertFalse(called)
        TestObject().noArgsNoReturnFunc()
        XCTAssertTrue(called)
    }
    
    func testHookBeforeSumFunc() {
        let arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
        let arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
        do {
            try TestObject.hookBefore(selector: #selector(TestObject.sumFunc), closure: {
            })
        } catch {
            XCTAssertNil(error)
        }
        let result = TestObject().sumFunc(a: arg1, b: arg2)
        XCTAssertEqual(result, arg1 + arg2)
    }
    
}
