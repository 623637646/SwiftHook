//
//  PerformanceTests.swift
//  PerformanceTests
//
//  Created by Yanni Wang on 26/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

// WARNING: Swift is very slow then Objective-C in Debug mode. So this test case should be run under release mode! Refer to: https://stackoverflow.com/q/61998649/9315497

class SwiftHookPerformanceTests: XCTestCase {

    func testHookBeforeEmptyMethod() {
        let testObject = TestObject()
        var count = 0
        let token = try? hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc)) {
            count += 1
        }
        // 0.046
        self.measure {
            for _ in 1 ... measureCount {
                testObject.noArgsNoReturnFunc()
            }
        }
        token?.cancelHook()
        XCTAssertEqual(count, measureCount * 10)
    }
    
    func testHookInsteadEmptyMethod() {
        let testObject = TestObject()
        var count = 0
        let token = try? hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: { original in
            count += 1
            original()
        } as @convention(block) (() -> Void) -> Void)
        // 0.39
        self.measure {
            for _ in 1 ... measureCount {
                testObject.noArgsNoReturnFunc()
            }
        }
        token?.cancelHook()
        XCTAssertEqual(count, measureCount * 10)
    }
    
    func testSingleHookAfterEmptyMethod() {
        let testObject = TestObject()
        var count = 0
        let token = try? hookAfter(object: testObject, selector: #selector(TestObject.noArgsNoReturnFunc)) {
            count += 1
        }
        // 0.18
        self.measure {
            for _ in 1 ... measureCount {
                testObject.noArgsNoReturnFunc()
            }
        }
        token?.cancelHook()
        XCTAssertEqual(count, measureCount * 10)
    }
    
    func testSingleHookInsteadEmptyMethod() {
        let testObject = TestObject()
        var count = 0
        let token = try? hookInstead(object: testObject, selector: #selector(TestObject.noArgsNoReturnFunc), closure: { original in
            count += 1
            original()
        } as @convention(block) (() -> Void) -> Void)
        // 0.6
        self.measure {
            for _ in 1 ... measureCount {
                testObject.noArgsNoReturnFunc()
            }
        }
        token?.cancelHook()
        XCTAssertEqual(count, measureCount * 10)
    }

}
