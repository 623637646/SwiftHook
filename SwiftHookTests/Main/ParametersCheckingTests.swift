//
//  ParametersCheckingTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

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
    
    func testRetainForSpecifiedInstance() {
        do {
            let object = ObjectiveCTestObject()
            try hookBefore(object: object, selector: NSSelectorFromString("retain")) {
            }
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .specifiedInstanceRetain)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testReleaseForSpecifiedInstance() {
        do {
            let object = ObjectiveCTestObject()
            try hookBefore(object: object, selector: NSSelectorFromString("release")) {
            }
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .specifiedInstanceRelease)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
