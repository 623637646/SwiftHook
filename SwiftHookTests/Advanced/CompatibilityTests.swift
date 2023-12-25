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
    func test_KVO() {
        var called = false
        let object = ObjectiveCTestObject()
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        let kvo = object.observe(\.number) { _, _ in
            called = true
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .normal))
        XCTAssertFalse(called)
        object.number = 2
        XCTAssertTrue(called)
        
        called = false
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        XCTAssertFalse(called)
        object.number = 3
        XCTAssertFalse(called)
    }
    
    func test_SwiftHook_KVO_cancel_KVO_cancel_SwiftHook() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.number) { _, _ in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.number, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.number = 10
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.number, 10)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 11)
    }
    
    func test_SwiftHook_KVO_cancel_SwiftHook_cancel_KVO() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.number) { _, _ in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.number, 9)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .normal))
        object.number = 10
        XCTAssertEqual(expectation, [2])
        XCTAssertEqual(object.number, 10)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 11)
    }
    
    func test_KVO_SwiftHook_cancel_SwiftHook_cancel_KVO() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let kvo = object.observe(\.number) { _, _ in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .normal))
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.number, 9)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .normal))
        object.number = 10
        XCTAssertEqual(expectation, [2])
        XCTAssertEqual(object.number, 10)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 11)
    }
    
    func test_KVO_SwiftHook_cancel_KVO_cancel_SwiftHook() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let kvo = object.observe(\.number) { _, _ in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .normal))
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.number, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.number = 11
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.number, 11)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.number = 10
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 10)
    }
    
    class MyObject: NSObject {
        @objc dynamic var property1: Int = 9
        @objc dynamic var property2: UIView?
    }
    
    func test_randomly() throws {
        
        enum HookLog {
            case KVO(token: NSKeyValueObservation, number: Int)
            case swiftHook(token: Token, start: Int, end: Int)
        }
        
        let object = MyObject()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        var property2Log = [HookLog]()
        var logs = [HookLog]()
        var order = [Int]()
        
        var token = try hookAfter(object: object, selector: #selector(setter: MyObject.property2)) {
        }
        property2Log.append(.swiftHook(token: token, start: 0, end: 0))
        var keyValueObservation = object.observe(\.property2) { _, _ in
        }
        property2Log.append(.KVO(token: keyValueObservation, number: 0))
        for _ in 0 ... Int.random(in: 0 ... 100) {
            if Bool.random() {
                // SwiftHook
                let start = Int.random(in: Int.min ... Int.max)
                let end = Int.random(in: Int.min ... Int.max)
                let token = try hookInstead(object: object, selector: #selector(setter: MyObject.property1), closure: { original, object, selector, number in
                    order.append(start)
                    original(object, selector, number)
                    order.append(end)
                } as @convention(block) ((MyObject, Selector, Int) -> Void, MyObject, Selector, Int) -> Void)
                logs.append(.swiftHook(token: token, start: start, end: end))
            } else {
                // KVO
                let number = Int.random(in: Int.min ... Int.max)
                let token = object.observe(\.property1) { _, _ in
                    order.append(number)
                }
                logs.append(.KVO(token: token, number: number))
            }
        }
        
        token = try hookAfter(object: object, selector: #selector(setter: MyObject.property2)) {
        }
        property2Log.append(.swiftHook(token: token, start: 0, end: 0))
        
        keyValueObservation = object.observe(\.property2) { _, _ in
        }
        property2Log.append(.KVO(token: keyValueObservation, number: 0))
        
        repeat {
            let number = Int.random(in: Int.min ... Int.max)
            object.property1 = number
            
            var orderCalculated = [Int]()
            orderCalculated.append(contentsOf: logs.flatMap { (log) -> [Int] in
                if case let .swiftHook(token: _, start: start, end: _) = log {
                    return [start]
                } else {
                    return []
                }
            }.reversed())
            orderCalculated.append(contentsOf: logs.flatMap { (log) -> [Int] in
                if case let .KVO(token: _, number: number) = log {
                    return [number]
                } else {
                    return []
                }
            }.reversed())
            orderCalculated.append(contentsOf: logs.flatMap { (log) -> [Int] in
                if case let .swiftHook(token: _, start: _, end: end) = log {
                    return [end]
                } else {
                    return []
                }
            })
            
            XCTAssertEqual(orderCalculated, order)
            XCTAssertEqual(object.property1, number)
            
            order = []
            let randomIndex = Int.random(in: 0 ... logs.count - 1)
            let aLog = logs[randomIndex]
            switch aLog {
            case let .swiftHook(token: token, start: _, end: _):
                token.cancelHook()
            case .KVO(token: let token, number: _):
                token.invalidate()
            }
            logs.remove(at: randomIndex)
        } while !logs.isEmpty
        
        guard !property2Log.isEmpty else {
            XCTAssertEqual(try testGetObjectType(object: object), .normal)
            let number = Int.random(in: Int.min ... Int.max)
            object.property1 = number
            XCTAssertEqual(order, [])
            XCTAssertEqual(object.property1, number)
            return
        }
        
        var hasSwiftHook = false
        property2Log.forEach { log in
            if case .swiftHook = log {
                hasSwiftHook = true
            }
        }
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: hasSwiftHook ? .swiftHook : .normal))
        XCTAssertEqual(order, [])
        var number = Int.random(in: Int.min ... Int.max)
        object.property1 = number
        XCTAssertEqual(order, [])
        XCTAssertEqual(object.property1, number)
        
        property2Log.forEach { log in
            if case let .swiftHook(token: token, start: _, end: _) = log {
                token.cancelHook()
            }
        }
        
        guard !property2Log.isEmpty else {
            XCTAssertEqual(try testGetObjectType(object: object), .normal)
            let number = Int.random(in: Int.min ... Int.max)
            object.property1 = number
            XCTAssertEqual(order, [])
            XCTAssertEqual(object.property1, number)
            return
        }
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: .normal))
        number = Int.random(in: Int.min ... Int.max)
        object.property1 = number
        XCTAssertEqual(order, [])
        XCTAssertEqual(object.property1, number)
        
        property2Log.forEach { log in
            if case let .KVO(token: token, number: _) = log {
                token.invalidate()
            }
        }
        
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        number = Int.random(in: Int.min ... Int.max)
        object.property1 = number
        XCTAssertEqual(order, [])
        XCTAssertEqual(object.property1, number)
    }
    
    class MyObject1: NSObject {
        @objc dynamic var obj: MyObject2?
    }
    class MyObject2: NSObject {
        @objc dynamic var obj: MyObject3 = MyObject3.init()
    }
    class MyObject3: NSObject {
        @objc dynamic var int: Int = 9
    }
    
    func test_KVO_SwiftHook_complicated_path() throws {
        
        let object = MyObject1.init()
        var order = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let kvo = object.observe(\.obj?.obj.int) { _, _ in
            order.append(2)
        }
        defer {
            _ = kvo
        }
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: .normal))
        
        _ = try hookInstead(object: object, selector: #selector(setter: MyObject1.obj), closure: { original, object, selector, number in
            order.append(1)
            original(object, selector, number)
            order.append(3)
        } as @convention(block) ((MyObject1, Selector, MyObject2) -> Void, MyObject1, Selector, MyObject2) -> Void)
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: .swiftHook))
        
        object.obj = MyObject2.init()
        XCTAssertEqual(order, [1, 2, 3])
        
        order = []
        object.obj!.obj.int = 10
        XCTAssertEqual(order, [2])
    }
    
    func test_SwiftHook_KVO_complicated_path() throws {
        let object = MyObject1.init()
        var order = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        _ = try hookInstead(object: object, selector: #selector(setter: MyObject1.obj), closure: { original, object, selector, number in
            order.append(1)
            original(object, selector, number)
            order.append(3)
        } as @convention(block) ((MyObject1, Selector, MyObject2) -> Void, MyObject1, Selector, MyObject2) -> Void)
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.obj?.obj.int) { _, _ in
            order.append(2)
        }
        defer {
            _ = kvo
        }
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: .swiftHook))
        
        object.obj = MyObject2.init()
        XCTAssertEqual(order, [1, 2, 3])
        
        order = []
        object.obj!.obj.int = 10
        XCTAssertEqual(order, [2])
    }
    
    func test_deinit() throws {
        class MyObject: NSObject {
            @objc dynamic var number: Int = 9
        }
        var order = [Int]()
        try autoreleasepool {
            let object = MyObject()
            XCTAssertTrue(try testGetObjectType(object: object) == .normal)
            
            let kvo = object.observe(\.number) { _, _ in
                order.append(0)
            }
            defer {
                _ = kvo
            }
            
            // before
            try hookBefore(object: object, selector: deallocSelector) {
                order.append(4)
            }
            try hookDeallocBefore(object: object, closure: {
                order.append(3)
            })
            
            // instead
            try hookInstead(object: object, selector: deallocSelector, closure: { original in
                order.append(2)
                original()
                order.append(8)
            } as @convention(block) (() -> Void) -> Void)
            try hookDeallocInstead(object: object, closure: { original in
                order.append(1)
                original()
                order.append(9)
            } as @convention(block) (() -> Void) -> Void)
            
            // after
            try hookAfter(object: object, selector: deallocSelector) {
                order.append(7)
            }
            try hookDeallocAfter(object: object, closure: {
                order.append(6)
            })
            hookDeallocAfterByTail(object: object, closure: {
                order.append(5)
            })
            XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
            
            XCTAssertEqual(order, [])
            
            object.number = 1
        }
        XCTAssertEqual(order, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func test_deinit_2() throws {
        class MyObject: NSObject {
            @objc dynamic var number: Int = 9
        }
        var order = [Int]()
        try autoreleasepool {
            let object = MyObject()
            XCTAssertTrue(try testGetObjectType(object: object) == .normal)
            
            // before
            try hookBefore(object: object, selector: deallocSelector) {
                order.append(4)
            }
            try hookDeallocBefore(object: object, closure: {
                order.append(3)
            })
            
            // instead
            try hookInstead(object: object, selector: deallocSelector, closure: { original in
                order.append(2)
                original()
                order.append(8)
            } as @convention(block) (() -> Void) -> Void)
            try hookDeallocInstead(object: object, closure: { original in
                order.append(1)
                original()
                order.append(9)
            } as @convention(block) (() -> Void) -> Void)
            
            let kvo = object.observe(\.number) { _, _ in
                order.append(0)
            }
            kvo.invalidate()
            
            // after
            try hookAfter(object: object, selector: deallocSelector) {
                order.append(7)
            }
            try hookDeallocAfter(object: object, closure: {
                order.append(6)
            })
            hookDeallocAfterByTail(object: object, closure: {
                order.append(5)
            })
            XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
            
            XCTAssertEqual(order, [])
            
            object.number = 1
        }
        XCTAssertEqual(order, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func test_deinit_3() throws {
        class MyObject: NSObject {
            @objc dynamic var number: Int = 9
        }
        var order = [Int]()
        try autoreleasepool {
            let object = MyObject()
            XCTAssertTrue(try testGetObjectType(object: object) == .normal)
            
            // before
            try hookBefore(object: object, selector: deallocSelector) {
                order.append(4)
            }
            try hookDeallocBefore(object: object, closure: {
                order.append(3)
            })
            
            // instead
            try hookInstead(object: object, selector: deallocSelector, closure: { original in
                order.append(2)
                original()
                order.append(8)
            } as @convention(block) (() -> Void) -> Void)
            try hookDeallocInstead(object: object, closure: { original in
                order.append(1)
                original()
                order.append(9)
            } as @convention(block) (() -> Void) -> Void)
            
            // after
            try hookAfter(object: object, selector: deallocSelector) {
                order.append(7)
            }
            try hookDeallocAfter(object: object, closure: {
                order.append(6)
            })
            hookDeallocAfterByTail(object: object, closure: {
                order.append(5)
            })
            
            let kvo = object.observe(\.number) { _, _ in
                order.append(0)
            }
            defer {
                _ = kvo
            }
            
            XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
            
            XCTAssertEqual(order, [])
            
            object.number = 1
        }
        XCTAssertEqual(order, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    // MARK: Aspects
    
    // This test case is not passed. Because Aspects is not compatible with KVOed object. For more information: "AspectsErrorTests: testCrashWithKVOedObject"
    
    //    func test_SwiftHook_Aspects() throws {
    //        let object = ObjectiveCTestObject()
    //        var expectation = [Int]()
    //        XCTAssertEqual(try testGetObjectType(object: object), .normal)
    //
    //        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
    //            expectation.append(1)
    //            original(o, s, number)
    //            expectation.append(2)
    //        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
    //        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
    //
    //        let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
    //            expectation.append(3)
    //            aspect.originalInvocation()?.invoke()
    //            expectation.append(4)
    //        } as @convention(block) (AspectInfo) -> Void)
    //        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
    //        XCTAssertEqual(expectation, [])
    //
    //        object.number = 9
    //        XCTAssertEqual(expectation, [3, 1, 2, 4])
    //        XCTAssertEqual(object.number, 9)
    //
    //        expectation = []
    //        XCTAssertTrue(tokenAspects.remove())
    //        XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
    //        object.number = 10
    //        XCTAssertEqual(expectation, [1, 2])
    //        XCTAssertEqual(object.number, 10)
    //
    //        expectation = []
    //        guard let hookToken = token as? HookToken else {
    //            XCTFail()
    //            return
    //        }
    //        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
    //        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
    //        object.number = 11
    //        XCTAssertEqual(expectation, [])
    //        XCTAssertEqual(object.number, 11)
    //    }
    
    func test_Aspects_SwiftHook_cancel_SwiftHook_cancel_Aspects() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
            expectation.append(2)
            aspect.originalInvocation()?.invoke()
            expectation.append(3)
        } as @convention(block) (AspectInfo) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .others)
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(4)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [1, 2, 3, 4])
        XCTAssertEqual(object.number, 9)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .others)
        object.number = 11
        XCTAssertEqual(expectation, [2, 3])
        XCTAssertEqual(object.number, 11)
        
        expectation = []
        XCTAssertTrue(tokenAspects.remove())
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.number = 10
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 10)
    }
    
    // This test case is not passed. Because Aspects is not compatible with KVOed object. For more information: AspectsErrorTests: testCrashOnCancellationAspectsAfterKVO
    //    func test_Aspects_SwiftHook_cancel_Aspects_cancel_SwiftHook() throws {
    //        let object = ObjectiveCTestObject()
    //        var expectation = [Int]()
    //        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
    //
    //        let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
    //            expectation.append(2)
    //            aspect.originalInvocation()?.invoke()
    //            expectation.append(3)
    //        } as @convention(block) (AspectInfo) -> Void)
    //        XCTAssertTrue(try testGetObjectType(object: object) == .others)
    //
    //        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
    //            expectation.append(1)
    //            original(o, s, number)
    //            expectation.append(4)
    //        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
    //        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
    //        XCTAssertEqual(expectation, [])
    //
    //        object.number = 9
    //        XCTAssertEqual(expectation, [1, 2, 3, 4])
    //        XCTAssertEqual(object.number, 9)
    //
    //        expectation = []
    //        XCTAssertTrue(tokenAspects.remove())
    //        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
    //        object.number = 10
    //        XCTAssertEqual(expectation, [2, 3])
    //        XCTAssertEqual(object.number, 10)
    //
    //        expectation = []
    //        guard let hookToken = token as? HookToken else {
    //            XCTFail()
    //            return
    //        }
    //        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
    //        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
    //        object.number = 11
    //        XCTAssertEqual(expectation, [])
    //        XCTAssertEqual(object.number, 11)
    //    }
    
    // MARK: Others
    
    func test_SwiftHook_change_IMP() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let method = class_getInstanceMethod(object_getClass(object), #selector(setter: ObjectiveCTestObject.number))!
        let newMethod = imp_implementationWithBlock({
            expectation.append(2)
        } as @convention(block) () -> Void)
        let originalIMP = method_setImplementation(method, newMethod)
        
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [2])
        XCTAssertEqual(object.number, 0)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertFalse(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.number = 11
        XCTAssertEqual(expectation, [2])
        XCTAssertEqual(object.number, 0)
        
        method_setImplementation(method, originalIMP)
        
        expectation = []
        object.number = 12
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 12)
    }
    
    func test_SwiftHook_change_class() throws {
        let object = ObjectiveCTestObject()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let baseClass: AnyClass = object_getClass(object)!
        let newClassName = "Test" + NSStringFromClass(baseClass)
        let newClass: AnyClass = objc_allocateClassPair(baseClass, newClassName, 0x68)!
        objc_registerClassPair(newClass)
        memcpy(object_getIndexedIvars(newClass)!, object_getIndexedIvars(baseClass)!, 0x68)
        object_setClass(object, newClass)
        XCTAssertTrue(try testGetObjectType(object: object) == .others)
        XCTAssertEqual(expectation, [])
        
        object.number = 9
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.number, 9)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertFalse(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .others)
        object.number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.number, 11)
    }
    
    func test_SwiftHook_on_class_change_IMP() throws {
        class MyOCObject: NSObject {
            @objc dynamic func myMethod() {
            }
        }
        
        class MySwiftObject {
            @objc dynamic func myMethod() {
            }
        }
        
        let token1 = try hookInstead(targetClass: MyOCObject.self, selector: #selector(MyOCObject.myMethod), closure: { original, o, s in
            original(o, s)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        guard let hookToken1 = token1 as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken1)!)
        
        let token2 = try hookInstead(targetClass: MySwiftObject.self, selector: #selector(MySwiftObject.myMethod), closure: { original, o, s in
            original(o, s)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        guard let hookToken2 = token2 as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken2)!)
        
        let token3 = try hookInstead(targetClass: MyOCObject.self, selector: #selector(MyOCObject.myMethod), closure: { original, o, s in
            original(o, s)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        let method3 = class_getInstanceMethod(MyOCObject.self, #selector(MyOCObject.myMethod))!
        let newMethod3 = imp_implementationWithBlock({} as @convention(block) () -> Void)
        _ = method_setImplementation(method3, newMethod3)
        guard let hookToken3 = token3 as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertFalse(try internalCancelHook(token: hookToken3)!)
        
        let token4 = try hookInstead(targetClass: MySwiftObject.self, selector: #selector(MySwiftObject.myMethod), closure: { original, o, s in
            original(o, s)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        let method4 = class_getInstanceMethod(MySwiftObject.self, #selector(MySwiftObject.myMethod))!
        let newMethod4 = imp_implementationWithBlock({} as @convention(block) () -> Void)
        _ = method_setImplementation(method4, newMethod4)
        guard let hookToken4 = token4 as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertFalse(try internalCancelHook(token: hookToken4)!)
    }
}
