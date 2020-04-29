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
    
    func testInstancesDoNotRespondSelector() {
        do {
            try TestObject.hookBefore(selector: #selector(NSArray.object(at:)), block: {})
            XCTAssertTrue(false)
        } catch SwiftHookError.instancesDoNotRespondSelector(let `class`, let selector) {
            XCTAssertTrue(`class` == TestObject.self)
            XCTAssertEqual(selector, #selector(NSArray.object(at:)))
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    // MARK: Before
    
    func testHookBeforeNoArgsNoReturnFunc() {
        var called = false
        try! TestObject.hookBefore(selector: #selector(TestObject.noArgsNoReturnFunc), block: {
            called = true
        })
        XCTAssertFalse(called)
        TestObject().noArgsNoReturnFunc()
        XCTAssertTrue(called)
    }
    
    // TODO: Not working
    func testHookBeforeSumFunc() {
        let arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
        let arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
        try! TestObject.hookBefore(selector: #selector(TestObject.sumFunc), block: {
            
        })
        let result = TestObject().sumFunc(a: arg1, b: arg2)
        XCTAssertEqual(result, arg1 + arg2)
    }
    
}
