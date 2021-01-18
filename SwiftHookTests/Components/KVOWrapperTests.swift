//
//  KVOWrapperTests.swift
//  SwiftHookTests
//
//  Created by Wang Ya on 1/14/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class KVOWrapperTests: XCTestCase {

    func test_regular() throws {
        class MyObject: NSObject {
            @objc dynamic func myMethod() {
            }
        }
        
        let object = MyObject.init()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        try wrapKVOIfNeeded(object: object, selector: #selector(MyObject.myMethod))
        XCTAssertEqual(try testGetObjectType(object: object), .KVOed(mode: .swiftHook))
        XCTAssertTrue(isWrappedKVO(object: object))
        
        unwrapKVOIfNeeded(object: object)
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        XCTAssertFalse(isWrappedKVO(object: object))
    }
    
    func test_getKVOName() throws {
        class MyObject: NSObject {
            @objc dynamic func myMethod() {
            }
            @objc var property1: Int = 9
            @objc var property2: NSAttributedString?
            @objc var property3: UIView? {
                get {
                    return nil
                }
                set {
                    _ = newValue
                }
            }
            
            @objc dynamic func property4() -> UIFont? {
                return nil
            }
            @objc dynamic func setProperty4(_ value: UIFont?) {
            }
            
            @objc dynamic func property5() -> UIView {
                return UIView.init()
            }
            @objc dynamic func setProperty5(_ value: NSDictionary) {
            }
            
            @objc var Property6: Double = 0.8
        }
        let object = MyObject.init()
        XCTAssertNil(getKVOName(object: object, setter: #selector(MyObject.myMethod)))
        XCTAssertEqual(getKVOName(object: object, setter: #selector(setter: MyObject.property1)), "Property1")
        XCTAssertEqual(getKVOName(object: object, setter: #selector(setter: MyObject.property2)), "Property2")
        XCTAssertEqual(getKVOName(object: object, setter: #selector(setter: MyObject.property3)), "Property3")
        XCTAssertEqual(getKVOName(object: object, setter: #selector(MyObject.setProperty4)), "Property4")
        XCTAssertEqual(getKVOName(object: object, setter: #selector(MyObject.setProperty5)), "Property5")
        XCTAssertEqual(getKVOName(object: object, setter: #selector(setter: MyObject.Property6)), "Property6")

    }
    
    // MARK: compatibility with KVO
    
    func test_normal() throws {
        class MyObject: NSObject {
            @objc dynamic var number: Int = 9
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.number) { (_, _) in
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
    
    func test_uppercase() throws {
        class MyObject: NSObject {
            @objc dynamic var Number: Int = 9
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.Number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.Number) { (_, _) in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.Number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.Number, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.Number = 10
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.Number, 10)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.Number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.Number, 11)
    }
    
    func test_setter_getter() throws {
        class MyObject: NSObject {
            private var _number = 9
            @objc dynamic var number: Int {
                get {
                    return self._number
                }
                set {
                    self._number = newValue
                }
            }
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.number) { (_, _) in
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
    
    func test_setter_getter_uppercase() throws {
        class MyObject: NSObject {
            private var _number = 9
            @objc dynamic var Number: Int {
                get {
                    return self._number
                }
                set {
                    self._number = newValue
                }
            }
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.Number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.Number) { (_, _) in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.Number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.Number, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.Number = 10
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.Number, 10)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.Number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.Number, 11)
    }
    
    func test_strange_property() throws {
        class MyObject: NSObject {
            @objc dynamic var ___number = 9
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.___number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.___number) { (_, _) in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.___number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.___number, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.___number = 10
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.___number, 10)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.___number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.___number, 11)
    }
    
    func test_strange_property_uppercase() throws {
        class MyObject: NSObject {
            @objc dynamic var ___Number = 9
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.___Number), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.___Number) { (_, _) in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.___Number = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.___Number, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.___Number = 10
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.___Number, 10)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.___Number = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.___Number, 11)
    }
    
    func test_special_property_name() throws {
        class MyObject: NSObject {
            @objc dynamic var swiftHookPrivateProperty: Int = 9
        }
        let object = MyObject.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: MyObject.swiftHookPrivateProperty), closure: { original, o, s, number in
            expectation.append(1)
            original(o, s, number)
            expectation.append(3)
        } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        
        let kvo = object.observe(\.swiftHookPrivateProperty) { (_, _) in
            expectation.append(2)
        }
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        XCTAssertEqual(expectation, [])
        
        object.swiftHookPrivateProperty = 9
        XCTAssertEqual(expectation, [1, 2, 3])
        XCTAssertEqual(object.swiftHookPrivateProperty, 9)
        
        expectation = []
        kvo.invalidate()
        XCTAssertTrue(try testGetObjectType(object: object) == .KVOed(mode: .swiftHook))
        object.swiftHookPrivateProperty = 10
        XCTAssertEqual(expectation, [1, 3])
        XCTAssertEqual(object.swiftHookPrivateProperty, 10)
        
        expectation = []
        guard let hookToken = token as? HookToken else {
            XCTFail()
            return
        }
        XCTAssertTrue(try internalCancelHook(token: hookToken)!)
        XCTAssertTrue(try testGetObjectType(object: object) == .normal)
        object.swiftHookPrivateProperty = 11
        XCTAssertEqual(expectation, [])
        XCTAssertEqual(object.swiftHookPrivateProperty, 11)
    }

}
