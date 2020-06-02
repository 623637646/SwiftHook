//
//  CompatibilityTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 21/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook
import Aspects

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
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertTrue(internalCancelHook(token: hookToken)!)
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 11)
        } catch {
            XCTAssertNil(error)
        }
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
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertFalse(internalCancelHook(token: hookToken)!)
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
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertTrue(internalCancelHook(token: hookToken)!)
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
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .KVOedObject)
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
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertTrue(internalCancelHook(token: hookToken)!)
            XCTAssertTrue(try testIsKVO(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [3])
            XCTAssertEqual(object.number, 10)
            XCTFail()
        } catch SwiftHookError.unsupport(value: let value) {
            XCTAssertEqual(value, .KVOedObject)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Aspects
    
    func testBeforeAspects() {
        do {
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
                expectation.append(1)
                original(number)
                expectation.append(2)
                } as @convention(block) ((Int) -> Void, Int) -> Void)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
                expectation.append(3)
                aspect.originalInvocation()?.invoke()
                expectation.append(4)
                } as @convention(block) (AspectInfo) -> Void)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [3, 1, 2, 4])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            XCTAssertTrue(tokenAspects.remove())
            XCTAssertTrue(try testIsDynamicClass(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [1, 2])
            XCTAssertEqual(object.number, 10)
            
            expectation = []
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertTrue(internalCancelHook(token: hookToken)!)
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 11)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // This test case shows Aspects isn't compatible with others.
    func testAfterAspects() {
//        do {
//            let object = ObjectiveCTestObject()
//            var expectation = [Int]()
//
//            let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
//                expectation.append(3)
//                aspect.originalInvocation()?.invoke()
//                expectation.append(4)
//                } as @convention(block) (AspectInfo) -> Void)
//            XCTAssertTrue(try testIsNormalClass(object: object))
//            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
//                expectation.append(1)
//                original(number)
//                expectation.append(2)
//                } as @convention(block) ((Int) -> Void, Int) -> Void)
//            XCTAssertTrue(try testIsDynamicClass(object: object))
//            XCTAssertEqual(expectation, [])
//
//            object.number = 9
//            XCTAssertEqual(expectation, [1, 3, 4, 2])
//            XCTAssertEqual(object.number, 9)
//
//            expectation = []
//            XCTAssertTrue(tokenAspects.remove())
//            XCTAssertTrue(try testIsDynamicClass(object: object))
//            object.number = 10
//            XCTAssertEqual(expectation, [1, 2])
//            XCTAssertEqual(object.number, 10)
//
//            expectation = []
//            guard let hookToken = token as? HookToken else {
//                XCTFail()
//                return
//            }
//            XCTAssertTrue(internalCancelHook(token: hookToken)!)
//            XCTAssertTrue(try testIsNormalClass(object: object))
//            object.number = 11
//            XCTAssertEqual(expectation, [])
//            XCTAssertEqual(object.number, 11)
//        } catch {
//            XCTAssertNil(error)
//        }
    }
    
    func testAfterAspectsReverseCancel() {
        do {
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
                expectation.append(3)
                aspect.originalInvocation()?.invoke()
                expectation.append(4)
                } as @convention(block) (AspectInfo) -> Void)
            XCTAssertTrue(try testIsNormalClass(object: object))
            let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
                expectation.append(1)
                original(number)
                expectation.append(2)
                } as @convention(block) ((Int) -> Void, Int) -> Void)
            XCTAssertTrue(try testIsDynamicClass(object: object))
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [1, 3, 4, 2])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            guard let hookToken = token as? HookToken else {
                XCTFail()
                return
            }
            XCTAssertTrue(internalCancelHook(token: hookToken)!)
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 11
            XCTAssertEqual(expectation, [3, 4])
            XCTAssertEqual(object.number, 11)
            
            expectation = []
            XCTAssertTrue(tokenAspects.remove())
            XCTAssertTrue(try testIsNormalClass(object: object))
            object.number = 10
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 10)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // TODO: If add this test cases. It will influence others.
//    func testAfterAspectsReverseCancelForAllInstances() {
//        do {
//            let object = ObjectiveCTestObject()
//            var expectation = [Int]()
//            
//            let tokenAspects = try ObjectiveCTestObject.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
//                expectation.append(3)
//                aspect.originalInvocation()?.invoke()
//                expectation.append(4)
//                } as @convention(block) (AspectInfo) -> Void)
//            let token = try hookInstead(targetClass: ObjectiveCTestObject.self, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, number in
//                expectation.append(1)
//                original(number)
//                expectation.append(2)
//                } as @convention(block) ((Int) -> Void, Int) -> Void)
//            XCTAssertEqual(expectation, [])
//            
//            object.number = 9
//            XCTAssertEqual(expectation, [1, 3, 4, 2])
//            XCTAssertEqual(object.number, 9)
//            
//            expectation = []
//            guard let hookToken = token as? HookToken else {
//                XCTFail()
//                return
//            }
//            XCTAssertTrue(internalCancelHook(token: hookToken)!)
//            object.number = 11
//            XCTAssertEqual(expectation, [3, 4])
//            XCTAssertEqual(object.number, 11)
//            
//            expectation = []
//            XCTAssertTrue(tokenAspects.remove())
//            object.number = 10
//            XCTAssertEqual(expectation, [])
//            XCTAssertEqual(object.number, 10)
//        } catch {
//            XCTAssertNil(error)
//        }
//    }
    
}
