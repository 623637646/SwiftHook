//
//  DynamicClassTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class DynamicClassTests: XCTestCase {
    
    let InternalWrapDynamicClass = 81
    let InternalUnwrapNonDynamicClass = 100
    
    func testNormal() {
        do {
            let testObject = TestObject()
            XCTAssertTrue(try testGetObjectType(object: testObject) == .normal)
            _ = try wrapDynamicClass(object: testObject)
            XCTAssertTrue(try testGetObjectType(object: testObject) == .dynamic)
            try unwrapDynamicClass(object: testObject)
            XCTAssertTrue(try testGetObjectType(object: testObject) == .normal)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testWrapDynamicClass() {
        do {
            let testObject = TestObject()
            XCTAssertTrue(try testGetObjectType(object: testObject) == .normal)
            
            _ = try wrapDynamicClass(object: testObject)
            XCTAssertTrue(try testGetObjectType(object: testObject) == .dynamic)
            
            do {
                _ = try wrapDynamicClass(object: testObject)
                XCTFail()
            } catch SwiftHookError.internalError(file: let file, line: let line) {
                XCTAssertTrue(file.hasSuffix("DynamicClass.swift"))
                XCTAssertEqual(line, InternalWrapDynamicClass)
            } catch {
                XCTAssertNil(error)
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testUnwrapNonDynamicClass() {
        do {
            let testObject = TestObject()
            XCTAssertTrue(try testGetObjectType(object: testObject) == .normal)
            do {
                try unwrapDynamicClass(object: testObject)
                XCTFail()
            } catch SwiftHookError.internalError(file: let file, line: let line) {
                XCTAssertTrue(file.hasSuffix("DynamicClass.swift"))
                XCTAssertEqual(line, InternalUnwrapNonDynamicClass)
            } catch {
                XCTAssertNil(error)
            }
            _ = try wrapDynamicClass(object: testObject)
            XCTAssertTrue(try testGetObjectType(object: testObject) == .dynamic)
            try unwrapDynamicClass(object: testObject)
            XCTAssertTrue(try testGetObjectType(object: testObject) == .normal)
            do {
                try unwrapDynamicClass(object: testObject)
                XCTFail()
            } catch SwiftHookError.internalError(file: let file, line: let line) {
                XCTAssertTrue(file.hasSuffix("DynamicClass.swift"))
                XCTAssertEqual(line, InternalUnwrapNonDynamicClass)
            } catch {
                XCTAssertNil(error)
            }
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // This test case and the next test case are to ensure that classes with the same name in different namespaces can be hooked normally.
    func test_Duplicated_Dynamic_Class_Name1() {
        class MyObject {
            @objc dynamic func test() {
            }
        }
        do {
            try hookBefore(object: MyObject.init(), selector: #selector(MyObject.test)) {
            }
        } catch {
            XCTFail()
        }
    }
    
    func test_Duplicated_Dynamic_Class_Name2() {
        class MyObject {
            @objc dynamic func test() {
            }
        }
        do {
            try hookBefore(object: MyObject.init(), selector: #selector(MyObject.test)) {
            }
        } catch {
            XCTFail()
        }
    }
    
}
