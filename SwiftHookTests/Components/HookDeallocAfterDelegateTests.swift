//
//  HookDeallocAfterDelegateTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 17/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookDeallocAfterDelegateTests: XCTestCase {
    
    func testSingleClosure() {
        var result = [Int]()
        autoreleasepool {
            let object =  randomTestObject()
            _ = hookDeallocAfterByDelegate(object: object, closure: {
                result.append(1)
            } as @convention(block) () -> Void as AnyObject)
        }
        XCTAssertEqual(result, [1])
    }
    
    func testMultipleClosure() {
        var result = [Int]()
        autoreleasepool {
            let object =  randomTestObject()
            _ = hookDeallocAfterByDelegate(object: object, closure: {
                result.append(1)
            } as @convention(block) () -> Void as AnyObject)
            _ = hookDeallocAfterByDelegate(object: object, closure: {
                result.append(2)
            } as @convention(block) () -> Void as AnyObject)
        }
        XCTAssertEqual(result, [2, 1])
    }
    
    func testCancellation() {
        var result = [Int]()
        autoreleasepool {
            let object =  randomTestObject()
            _ = hookDeallocAfterByDelegate(object: object, closure: {
                result.append(1)
            } as @convention(block) () -> Void as AnyObject)
            let token = hookDeallocAfterByDelegate(object: object, closure: {
                result.append(2)
            } as @convention(block) () -> Void as AnyObject)
            token.cancelHook()
        }
        XCTAssertEqual(result, [1])
    }
    
}
