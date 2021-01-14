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
    
    func test_getGetterMethodName() throws {
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
        }
        let object = MyObject.init()
        XCTAssertNil(getGetterMethodName(object: object, selector: #selector(MyObject.myMethod)))
        XCTAssertEqual(getGetterMethodName(object: object, selector: #selector(setter: MyObject.property1)), NSStringFromSelector(#selector(getter: MyObject.property1)))
        XCTAssertEqual(getGetterMethodName(object: object, selector: #selector(setter: MyObject.property2)), NSStringFromSelector(#selector(getter: MyObject.property2)))
        XCTAssertEqual(getGetterMethodName(object: object, selector: #selector(setter: MyObject.property3)), NSStringFromSelector(#selector(getter: MyObject.property3)))
        XCTAssertEqual(getGetterMethodName(object: object, selector: #selector(MyObject.setProperty4)), NSStringFromSelector(#selector(MyObject.property4)))
        XCTAssertEqual(getGetterMethodName(object: object, selector: #selector(MyObject.setProperty5)), NSStringFromSelector(#selector(MyObject.property5)))

    }

}
