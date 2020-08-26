//
//  ParametersCheckingTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

private let retainSelector = NSSelectorFromString("retain")
private let releaseSelector = NSSelectorFromString("release")
private let autoreleaseSelector = NSSelectorFromString("autorelease")
private let blacklistSelectors = [retainSelector, releaseSelector, autoreleaseSelector]

// TODO: 移除了很多 SignatureTests 里的 testcase，检查是否需要更全面的 ParametersCheckingTests？
class ParametersCheckingTests: XCTestCase {
    
    func testCanNotHookClassWithObjectAPI() {
        do {
            try hookBefore(object: randomTestClass(), selector: randomSelector(), closure: {
            })
            XCTFail()
        } catch SwiftHookError.canNotHookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: randomTestClass(), selector: randomSelector(), closure: {
            })
            XCTFail()
        } catch SwiftHookError.canNotHookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: randomTestClass(), selector: randomSelector(), closure: {
            })
            XCTFail()
        } catch SwiftHookError.canNotHookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testUnsupportHookPureSwiftObjectDealloc() {
        do {
            try hookBefore(object: TestObject(), selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .pureSwiftObjectDealloc)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: TestObject(), selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .pureSwiftObjectDealloc)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: TestObject(), selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .pureSwiftObjectDealloc)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookBefore(targetClass: TestObject.self, selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .pureSwiftObjectDealloc)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(targetClass: TestObject.self, selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .pureSwiftObjectDealloc)
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .pureSwiftObjectDealloc)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNoRespondSelector() {
        do {
            try hookBefore(targetClass: randomTestClass(), selector: #selector(NSArray.object(at:)), closure: {})
            XCTFail()
        } catch SwiftHookError.noRespondSelector {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookClassMethodAfter(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {})
            XCTFail()
        } catch SwiftHookError.noRespondSelector {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: TestObject(), selector: #selector(TestObject.classMethodNoArgsNoReturnFunc), closure: {})
            XCTFail()
        } catch SwiftHookError.noRespondSelector {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testMissingSignature() {
        do {
            try hookBefore(targetClass: randomTestClass(), selector: #selector(TestObject.noArgsNoReturnFunc), closure: NSObject())
            XCTFail()
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookClassMethodAfter(targetClass: TestObject.self, selector: #selector(TestObject.classMethodNoArgsNoReturnFunc), closure: 1)
            XCTFail()
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: TestObject(), selector: #selector(TestObject.noArgsNoReturnFunc), closure: {} as AnyObject)
            XCTFail()
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testIncompatibleClosureSignature() {
        do {
            try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { _, _ in
                return 1
                } as @convention(block) (Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: TestObject(), selector: #selector(TestObject.sumFunc(a:b:)), closure: { _, _ in
                } as @convention(block) (Int, Double) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: TestObject(), selector: #selector(TestObject.testStructSignature(point:rect:)), closure: ({_, _ in
                } as @convention(block) (CGPoint, Double) -> Void) as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { _, _ in
                } as @convention(block) (Int, Int) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testBlacklist() {
        for selector in blacklistSelectors {
            do {
                let object = ObjectiveCTestObject()
                try hookBefore(object: object, selector: selector) {
                }
                XCTFail()
            } catch SwiftHookError.unsupport(value: let value) {
                XCTAssertEqual(value, .blacklist)
            } catch {
                XCTAssertNil(error)
            }
            
            do {
                try hookBefore(targetClass: ObjectiveCTestObject.self, selector: selector) {
                }
                XCTFail()
            } catch SwiftHookError.unsupport(value: let value) {
                XCTAssertEqual(value, .blacklist)
            } catch {
                XCTAssertNil(error)
            }
        }
    }
    
    func testHookInsteadOriginalClosureParametersWrong() {
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
                let result = original(a, b)
                return Int(result)
                } as @convention(block) ((Int, Int) -> Double, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, _, b in
                let result = original(NSObject.init(), b)
                return Int(result)
                } as @convention(block) ((NSObject, Int) -> Int, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
                let result = original(a, b, 100)
                return Int(result)
                } as @convention(block) ((Int, Int, Int) -> Int, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, _ in
                let result = original(a)
                return Int(result)
                } as @convention(block) ((Int) -> Int, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Hook_Dealloc_With_Object_And_Selector() {
        do {
            try hookBefore(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original, o, s in
                original(o, s)
                } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: ObjectiveCTestObject(), selector: deallocSelector, closure: { original, o, s in
                original(o, s)
                } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original, o, s in
                original(o, s)
                } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: ObjectiveCTestObject(), selector: deallocSelector, closure: { original, o, s in
                original(o, s)
                } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
}
