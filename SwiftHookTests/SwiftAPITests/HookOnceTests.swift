//
//  HookOnceTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 30/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import XCTest
import SwiftHook

class HookOnceTests: XCTestCase {

    func test_specific_object() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod() {
                self.run = true
            }
        }
        
        let obj = MyObject()
        var run = false
        var token: Token?
        token = try hookBefore(object: obj, selector: #selector(MyObject.myMethod)) {
            run = true
            token?.revert()
        }
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        obj.myMethod()
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
        
        obj.run = false
        run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        obj.myMethod()
        XCTAssertTrue(obj.run)
        XCTAssertFalse(run)
    }
    
    func test_objects() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod() {
                self.run = true
            }
        }
        
        var run = false
        var token: Token?
        token = try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) {
            run = true
            token?.revert()
        }
        let obj1 = MyObject()
        XCTAssertFalse(obj1.run)
        XCTAssertFalse(run)
        obj1.myMethod()
        XCTAssertTrue(obj1.run)
        XCTAssertTrue(run)
        
        let obj2 = MyObject()
        run = false
        XCTAssertFalse(obj2.run)
        XCTAssertFalse(run)
        obj2.myMethod()
        XCTAssertTrue(obj2.run)
        XCTAssertFalse(run)
    }

}
