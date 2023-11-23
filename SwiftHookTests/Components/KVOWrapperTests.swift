//
//  KVOWrapperTests.swift
//  SwiftHookTests
//
//  Created by Wang Ya on 1/14/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook
import Aspects

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
        XCTAssertNil(try getKVOName(object: object, setter: #selector(MyObject.myMethod)))
        XCTAssertEqual(try getKVOName(object: object, setter: #selector(setter: MyObject.property1)), "property1")
        XCTAssertEqual(try getKVOName(object: object, setter: #selector(setter: MyObject.property2)), "property2")
        XCTAssertEqual(try getKVOName(object: object, setter: #selector(setter: MyObject.property3)), "property3")
        XCTAssertEqual(try getKVOName(object: object, setter: #selector(MyObject.setProperty4)), "property4")
        XCTAssertEqual(try getKVOName(object: object, setter: #selector(MyObject.setProperty5)), "property5")
        XCTAssertEqual(try getKVOName(object: object, setter: #selector(setter: MyObject.Property6)), "Property6")
        XCTAssertEqual(try getKVOName(object: OperationQueue.init(), setter: #selector(setter: OperationQueue.name)), "name")

    }
    
    func test_isKVOed() throws {
        class SwiftObject: NSObject {
            @objc dynamic var number: Int = 9
        }
        class NSKVONotifying_SwiftObject: NSObject {
            @objc dynamic var number: Int = 9
        }
        
        // aspect -> swiftHook
        try {
            let run = { (_ object: NSObject) in
                var expectation = [Int]()
                XCTAssertFalse(try isKVOed(object: object))
                let random1 = Int.random(in: Int.min ... Int.max)
                let random2 = Int.random(in: Int.min ... Int.max)
                let random3 = Int.random(in: Int.min ... Int.max)
                let random4 = Int.random(in: Int.min ... Int.max)

                try object.aspect_hook(#selector(setter: SwiftObject.number), with: .positionBefore, usingBlock: { _ in
                    expectation.append(random1)
                } as @convention(block) (AspectInfo) -> Void)
                XCTAssertFalse(try isKVOed(object: object))
                object.setValue(random2, forKey: "number")
                XCTAssertTrue(object.value(forKey: "number") as! Int == random2)
                XCTAssertEqual(expectation, [random1])
                expectation.removeAll()
                
                try hookBefore(object: object, selector: #selector(setter: SwiftObject.number), closure: {
                    expectation.append(random3)
                })
                XCTAssertTrue(try isKVOed(object: object))
                object.setValue(random4, forKey: "number")
                XCTAssertTrue(object.value(forKey: "number") as! Int == random4)
                XCTAssertEqual(expectation, [random3, random1])
            }
            
            try run(SwiftObject.init())
            try run(NSKVONotifying_SwiftObject.init())
            try run(SwiftHook_MyClass.init())
            try run(NSKVONotifying_MyClass.init())
        }()
        
        // setClass -> swiftHook
        try {
            let run = { (_ object: NSObject) in
                var expectation = [Int]()
                XCTAssertFalse(try isKVOed(object: object))
                let random1 = Int.random(in: Int.min ... Int.max)
                let random2 = Int.random(in: Int.min ... Int.max)

                let baseClass: AnyClass = object_getClass(object)!
                let newClassName = "Test" + "\(ObjectIdentifier(baseClass).hashValue)"
                let newClass: AnyClass = objc_allocateClassPair(baseClass, newClassName, 0)!
                objc_registerClassPair(newClass)
                try hookInstead(targetClass: newClass, selector: NSSelectorFromString("class"), closure: { original, obj, select in
                    XCTAssertTrue(original(obj, select) == newClass)
                    return baseClass
                } as @convention(block) ((NSObject, Selector) -> AnyClass, NSObject, Selector) -> AnyClass)
                object_setClass(object, newClass)
                XCTAssertFalse(try isKVOed(object: object))
                XCTAssertTrue(sht_getClass(object) == baseClass)
                
                try hookBefore(object: object, selector: #selector(setter: SwiftObject.number), closure: {
                    expectation.append(random1)
                })
                XCTAssertTrue(try isKVOed(object: object))
                object.setValue(random2, forKey: "number")
                XCTAssertTrue(object.value(forKey: "number") as! Int == random2)
                XCTAssertEqual(expectation, [random1])
            }
            
            try run(SwiftObject.init())
            try run(NSKVONotifying_SwiftObject.init())
            try run(SwiftHook_MyClass.init())
            try run(NSKVONotifying_MyClass.init())
        }()
        
        // swiftHook -> setClass
        try {
            let run = { (_ object: NSObject) in
                var expectation = [Int]()
                let originalClass: AnyClass = object_getClass(object)!
                XCTAssertFalse(try isKVOed(object: object))
                let random1 = Int.random(in: Int.min ... Int.max)
                let random2 = Int.random(in: Int.min ... Int.max)
                
                try hookBefore(object: object, selector: #selector(setter: SwiftObject.number), closure: {
                    expectation.append(random1)
                })
                XCTAssertTrue(try isKVOed(object: object))
                object.setValue(random2, forKey: "number")
                XCTAssertTrue(object.value(forKey: "number") as! Int == random2)
                XCTAssertEqual(expectation, [random1])
                
                let baseClass: AnyClass = object_getClass(object)!
                let newClassName = "Test" + "\(ObjectIdentifier(baseClass).hashValue)"
                let newClass: AnyClass = objc_allocateClassPair(baseClass, newClassName, 0x68)!
                objc_registerClassPair(newClass)
                memcpy(object_getIndexedIvars(newClass)!, object_getIndexedIvars(baseClass)!, 0x68)
                object_setClass(object, newClass)
                XCTAssertTrue(try isKVOed(object: object))
                XCTAssertTrue(sht_getClass(object) == originalClass)
            }
            try run(SwiftObject.init())
            try run(NSKVONotifying_SwiftObject.init())
            try run(SwiftHook_MyClass.init())
            try run(NSKVONotifying_MyClass.init())
        }()
    }
    
    func test_isSupportedKVO() throws {
        try {
            let object = NSURL.init(string: "https://www.google.com")!
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertFalse(try isSupportedKVO(object: object))
            let keyValueObservation = object.observe(\.absoluteString, changeHandler: { (_, _) in
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertFalse(try isSupportedKVO(object: object))
            keyValueObservation.invalidate()
        }()
        try {
            let object = NSString.init(string: "???")
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertFalse(try isSupportedKVO(object: object))
            let keyValueObservation = object.observe(\.length, changeHandler: { (_, _) in
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertFalse(try isSupportedKVO(object: object))
            keyValueObservation.invalidate()
        }()
        
        try {
            let object = NSArray.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertFalse(try isSupportedKVO(object: object))
            XCTAssertThrowsError(try SwiftHookUtilities.catchException {
                _ = object.observe(\.count, changeHandler: { (_, _) in
                })
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertFalse(try isSupportedKVO(object: object))
        }()
        try {
            let object = NSSet.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertFalse(try isSupportedKVO(object: object))
            XCTAssertThrowsError(try SwiftHookUtilities.catchException {
                _ = object.observe(\.count, changeHandler: { (_, _) in
                })
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertFalse(try isSupportedKVO(object: object))
        }()
        try {
            let object = NSOrderedSet.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertFalse(try isSupportedKVO(object: object))
            XCTAssertThrowsError(try SwiftHookUtilities.catchException {
                _ = object.observe(\.count, changeHandler: { (_, _) in
                })
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertFalse(try isSupportedKVO(object: object))
        }()
        try {
            let object = Operation.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertTrue(try isSupportedKVO(object: object))
            object.addObserver(self, forKeyPath: "aaaaaaa", options: .new, context: nil)
            XCTAssertTrue(object_getClass(object)! != baseClass)
            XCTAssertTrue(try isSupportedKVO(object: object))
            object.removeObserver(self, forKeyPath: "aaaaaaa")
        }()
        try {
            let object = OperationQueue.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertTrue(try isSupportedKVO(object: object))
            let keyValueObservation = object.observe(\.isSuspended, changeHandler: { (_, _) in
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertTrue(try isSupportedKVO(object: object))
            keyValueObservation.invalidate()
        }()
        try {
            let object = NSDictionary.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertFalse(try isSupportedKVO(object: object))
            let keyValueObservation = object.observe(\.count, changeHandler: { (_, _) in
            })
            XCTAssertTrue(object_getClass(object)! == baseClass)
            XCTAssertFalse(try isSupportedKVO(object: object))
            keyValueObservation.invalidate()
        }()
        try {
            let object = UIView.init()
            let baseClass: AnyClass = object_getClass(object)!
            XCTAssertTrue(try isSupportedKVO(object: object))
            let keyValueObservation = object.observe(\.center, changeHandler: { (_, _) in
            })
            XCTAssertTrue(object_getClass(object)! != baseClass)
            XCTAssertTrue(try isSupportedKVO(object: object))
            keyValueObservation.invalidate()
        }()
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
    
    func test_special_class_name_swift_NSKVONotifying_MyClass() throws {
        class NSKVONotifying_MyClass: NSObject {
            @objc dynamic var swiftHookPrivateProperty: Int = 9
        }
        let object = NSKVONotifying_MyClass.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: NSKVONotifying_MyClass.swiftHookPrivateProperty), closure: { original, o, s, number in
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
    
    func test_special_class_name_objective_c_NSKVONotifying_MyClass() throws {
        let object = NSKVONotifying_MyClass.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: NSKVONotifying_MyClass.swiftHookPrivateProperty), closure: { original, o, s, number in
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
    
    func test_special_class_name_swift_SwiftHook_MyClass() throws {
        class SwiftHook_MyClass: NSObject {
            @objc dynamic var swiftHookPrivateProperty: Int = 9
        }
        let object = SwiftHook_MyClass.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: SwiftHook_MyClass.swiftHookPrivateProperty), closure: { original, o, s, number in
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
    
    func test_special_class_name_objective_c_SwiftHook_MyClass() throws {
        let object = SwiftHook_MyClass.init()
        var expectation = [Int]()
        XCTAssertEqual(try testGetObjectType(object: object), .normal)
        
        let token = try hookInstead(object: object, selector: #selector(setter: SwiftHook_MyClass.swiftHookPrivateProperty), closure: { original, o, s, number in
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
