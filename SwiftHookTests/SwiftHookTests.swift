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
    
    func testNoRespondSelector() {
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
    
    func testMissingSignature() {
        // before
        do {
            try TestObject.hookBefore(selector: #selector(TestObject.noArgsNoReturnFunc), closure: {} as Any)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        
        // after
        do {
            try TestObject.hookAfter(selector: #selector(TestObject.noArgsNoReturnFunc), closure: 1)
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
        
        // instead
        do {
            try TestObject.hookInstead(selector: #selector(TestObject.noArgsNoReturnFunc), closure: NSObject())
            XCTAssertTrue(false)
        } catch SwiftHookError.missingSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testIncompatibleClosureSignature() {
        // before
        do {
            try TestObject.hookBefore(selector: #selector(TestObject.noArgsNoReturnFunc), closure: {_ in
                
                } as @convention(block) (Int) -> Void)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
            
        } catch {
            XCTAssertNil(error)
        }
        
        // after
        do {
            try TestObject.hookAfter(selector: #selector(TestObject.execute(closure:)), closure: {_ in
                
                } as @convention(block) (String) -> Void)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
        
        // instead
        do {
            try TestObject.hookInstead(selector: #selector(TestObject.noArgsNoReturnFunc), closure: {
            
            } as @convention(block) () -> Void)
            XCTAssertTrue(false)
        } catch SwiftHookError.incompatibleClosureSignature {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookClassMethodWithInstanceSelector() {
        do {
            try TestObject.hookClassMethodBefore(selector: #selector(TestObject.noArgsNoReturnFunc), closure: {})
            XCTAssertTrue(false)
        } catch SwiftHookError.noRespondSelector(let targetClass, let selector) {
            XCTAssertTrue(targetClass == object_getClass(TestObject.self))
            XCTAssertEqual(selector, #selector(TestObject.noArgsNoReturnFunc))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookInstanceMethodWithClassMethodSelector() {
        do {
            try TestObject.hookBefore(selector: #selector(TestObject.classMethodNoArgsNoReturnFunc), closure: {})
            XCTAssertTrue(false)
        } catch SwiftHookError.noRespondSelector(let targetClass, let selector) {
            XCTAssertTrue(targetClass == TestObject.self)
            XCTAssertEqual(selector, #selector(TestObject.classMethodNoArgsNoReturnFunc))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Before
    
    func testHookBeforeNoArgsNoReturnFunc() {
        var called = false
        do {
            let hookContext = try TestObject.hookBefore(selector: #selector(TestObject.noArgsNoReturnFunc), closure: {
                called = true
            })
            XCTAssertFalse(called)
            TestObject().noArgsNoReturnFunc()
            XCTAssertTrue(called)
            XCTAssertTrue(hookContext.cancelHook()!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testHookBeforeSumFunc() {
        let arg1 = Int.random(in: Int.min / 2 ... Int.max / 2)
        let arg2 = Int.random(in: Int.min / 2 ... Int.max / 2)
        do {
            let hookContext = try TestObject.hookBefore(selector: #selector(TestObject.sumFunc), closure: {
            })
            let result = TestObject().sumFunc(a: arg1, b: arg2)
            XCTAssertEqual(result, arg1 + arg2)
            XCTAssertTrue(hookContext.cancelHook()!)
        } catch {
            XCTAssertNil(error)
        }
    }
    
}

// TODO: performance tests measureBlock
// TODO: test cases 多线程, Swift 属性是否需要加锁？ https://gist.github.com/623637646/43c4561cdf128e99eda124cd79bd6c16
