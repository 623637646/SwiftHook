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
    
    // MARK: Parameters Check
    
    func testMissingSignature() {
        // before
        do {
            try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {} as Any)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        
        // after
        do {
            try hookAfter(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: 1)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        
        // instead
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: NSObject())
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testIncompatibleClosureSignature() {
        // before
        do {
            try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {_ in
                
                } as @convention(block) (Int) -> Void)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
            
        } catch {
            XCTAssertNil(error)
        }
        
        // after
        do {
            try hookAfter(targetClass: TestObject.self, selector: #selector(TestObject.execute(closure:)), closure: {_ in
                
                } as @convention(block) (String) -> Void)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        
        // instead
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {
            
            } as @convention(block) () -> Void)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Before
    
    func testHookBeforeNoArgsNoReturnFunc() {
        var called = false
        do {
            guard let token = try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {
                called = true
            }) as? HookToken else {
                XCTAssert(false)
                return
            }
            XCTAssertFalse(called)
            TestObject().noArgsNoReturnFunc()
            XCTAssertTrue(called)
            XCTAssertTrue(internalCancelHook(token: token)!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookBeforeSumFunc() {
        let arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
        let arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
        do {
            guard let token = try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc), closure: {
            }) as? HookToken else {
                XCTAssert(false)
                return
            }
            let result = TestObject().sumFunc(a: arg1, b: arg2)
            XCTAssertEqual(result, arg1 + arg2)
            XCTAssertTrue(internalCancelHook(token: token)!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // TODO: 整理一下的testCase
//    func testCancelHookAfterObjectReleased() {
//        do {
//            let contextCount = debugGetNormalClassHookContextsCount()
//            try autoreleasepool {
//                let testObject = TestObject()
//                try hookBefore(object: testObject, selector: #selector(TestObject.noArgsNoReturnFunc)) {
//                }
//                XCTAssertEqual(debugGetNormalClassHookContextsCount(), contextCount + 2)
//            }
//            XCTAssertEqual(debugGetNormalClassHookContextsCount(), contextCount)
//        } catch {
//            XCTAssertNil(error)
//        }
//    }
    
    func testResetClassAfterCancel() {
        do {
            var object: AnyObject = TestObject()
            XCTAssertFalse(try testIsDynamicClass(object: object))
            var token = try hookBefore(object: object, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {
            })
            XCTAssertTrue(try testIsDynamicClass(object: object))
            token.cancelHook()
            XCTAssertFalse(try testIsDynamicClass(object: object))
            
            object = ObjectiveCTestObject()
            XCTAssertFalse(try testIsDynamicClass(object: object))
            token = try hookBefore(object: object, selector: #selector(ObjectiveCTestObject.noArgsNoReturnFunc), closure: {
            })
            XCTAssertTrue(try testIsDynamicClass(object: object))
            token.cancelHook()
            XCTAssertFalse(try testIsDynamicClass(object: object))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNoClassChangeForSwiftObject() {
        do {
            let swiftObject = TestObject()
            XCTAssertFalse(try testIsDynamicClass(object: swiftObject))
            var token = try hookDeallocAfterByTail(object: swiftObject) {
            }
            XCTAssertFalse(try testIsDynamicClass(object: swiftObject))
            token.cancelHook()
            XCTAssertFalse(try testIsDynamicClass(object: swiftObject))
            
            let ocObject = ObjectiveCTestObject()
            XCTAssertFalse(try testIsDynamicClass(object: ocObject))
            token = try hookDeallocAfter(object: ocObject) {
            }
            XCTAssertTrue(try testIsDynamicClass(object: ocObject))
            token.cancelHook()
            XCTAssertFalse(try testIsDynamicClass(object: ocObject))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testTemp1() {
        do {
            var result = [Int]()
            try hookBefore(object: ObjectiveCTestObject.self as AnyObject, selector: #selector(ObjectiveCTestObject.classNoArgsNoReturnFunc)) {
                result.append(8)
            }
            ObjectiveCTestObject.classNoArgsNoReturnFunc()
            ObjectiveCTestObject.classNoArgsNoReturnFunc()
            ObjectiveCTestObject.classNoArgsNoReturnFunc()
            XCTAssertEqual(result, [8, 8, 8])
            XCTAssertTrue(false)
        } catch SwiftHookError.canNotHookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
    }
}

// TODO: performance tests measureBlock
// TODO: test cases 多线程, Swift 属性是否需要加锁？ https://gist.github.com/623637646/43c4561cdf128e99eda124cd79bd6c16
