//
//  CompatibilityTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 21/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

// TODO: Compatibility testing （KVO, swizzling, aspects）
class CompatibilityTests: XCTestCase {
    
    // MARK: KVO
    func testKVO() {
        var called = false
        let object = ObjectiveCTestObject()
        let kvo = object.observe(\.number) { (_, _) in
            called = true
        }
        
        XCTAssertFalse(called)
        object.number = 2
        XCTAssertTrue(called)
        
        called = false
        kvo.invalidate()
        XCTAssertFalse(called)
        object.number = 3
        XCTAssertFalse(called)
    }
    
    func testBeforeKVO() {
        do {
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
                expectation.append(1)
                original(number)
                expectation.append(2)
                } as @convention(block) ((Int) -> Void, Int) -> Void)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            let kvo = object.observe(\.number) { (_, _) in
                expectation.append(3)
            }
            XCTAssertTrue(try testIsDynamicClassThenKVO(object: object))
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [1, 2, 3])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            kvo.invalidate()
            XCTAssertTrue(try testIsDynamicClass(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [1, 2])
            XCTAssertEqual(object.number, 10)
            
            expectation = []
            token.cancelHook()
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 11)
        } catch {
            XCTAssertNil(error)
        }
        debug_cleanUp()
    }
    
    func testBeforeKVOReverseCancel() {
        do {
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
                expectation.append(1)
                original(number)
                expectation.append(2)
                } as @convention(block) ((Int) -> Void, Int) -> Void)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            let kvo = object.observe(\.number) { (_, _) in
                expectation.append(3)
            }
            XCTAssertTrue(try testIsDynamicClassThenKVO(object: object))
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [1, 2, 3])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            token.cancelHook()
            XCTAssertTrue(try testIsDynamicClassThenKVO(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [3])
            XCTAssertEqual(object.number, 10)
            
            expectation = []
            kvo.invalidate()
            XCTAssertTrue(try testIsDynamicClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 11)
        } catch {
            XCTAssertNil(error)
        }
        debug_cleanUp()
    }
    
    func testAfterKVO() {
        do {
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let kvo = object.observe(\.number) { (_, _) in
                expectation.append(3)
            }
            XCTAssertTrue(try testIsKVO(object: object))
            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
                expectation.append(1)
                original(number)
                expectation.append(2)
                } as @convention(block) ((Int) -> Void, Int) -> Void)
            XCTAssertTrue(try testIsKVOThenDynamicClass(object: object))
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [1, 2, 3])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            token.cancelHook()
            XCTAssertTrue(try testIsKVO(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [3])
            XCTAssertEqual(object.number, 10)
            
            expectation = []
            kvo.invalidate()
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 11)
            XCTAssertTrue(false)
        } catch SwiftHookError.unsupportHookKVOedObject {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAfterKVOReverseCancel() {
        do {
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let kvo = object.observe(\.number) { (_, _) in
                expectation.append(3)
            }
            XCTAssertTrue(try testIsKVO(object: object))
            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
                expectation.append(1)
                original(number)
                expectation.append(2)
                } as @convention(block) ((Int) -> Void, Int) -> Void)
            XCTAssertTrue(try testIsKVOThenDynamicClass(object: object))
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [1, 2, 3])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            kvo.invalidate()
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 11)
            
            expectation = []
            token.cancelHook()
            XCTAssertTrue(try testIsKVO(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [3])
            XCTAssertEqual(object.number, 10)
            XCTAssertTrue(false)
        } catch SwiftHookError.unsupportHookKVOedObject {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Aspects
    
    func testBeforeAspects() {
        
    }
    
    func testAfterAspects() {
        
    }
    
    func testAComplicatedCase() {
        
    }
    
}
