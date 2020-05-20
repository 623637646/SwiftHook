//
//  DynamicClassContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class DynamicClassContextTests: XCTestCase {
    
    let InternalWrapDynamicClass = 57
    let InternalUnwrapNonDynamicClass = 75
    
    override class func setUp() {
        cleanUpDynamicClassContextPool()
    }
    
    func testNormal() {
        do {
            let testObject = TestObject()
            XCTAssertFalse(try testIsDynamicClass(object: testObject))
            _ = try wrapDynamicClass(object: testObject)
            XCTAssertTrue(try testIsDynamicClass(object: testObject))
            try unwrapDynamicClass(object: testObject)
            XCTAssertFalse(try testIsDynamicClass(object: testObject))
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testWrapDynamicClass() {
        do {
            let testObject = TestObject()
            XCTAssertFalse(try testIsDynamicClass(object: testObject))
            
            _ = try wrapDynamicClass(object: testObject)
            XCTAssertTrue(try testIsDynamicClass(object: testObject))
            
            do {
                _ = try wrapDynamicClass(object: testObject)
                XCTAssertTrue(false)
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
            XCTAssertFalse(try testIsDynamicClass(object: testObject))
            do {
                try unwrapDynamicClass(object: testObject)
                XCTAssertTrue(false)
            } catch SwiftHookError.internalError(file: let file, line: let line) {
                XCTAssertTrue(file.hasSuffix("DynamicClass.swift"))
                XCTAssertEqual(line, InternalUnwrapNonDynamicClass)
            } catch {
                XCTAssertNil(error)
            }
            _ = try wrapDynamicClass(object: testObject)
            XCTAssertTrue(try testIsDynamicClass(object: testObject))
            try unwrapDynamicClass(object: testObject)
            XCTAssertFalse(try testIsDynamicClass(object: testObject))
            do {
                try unwrapDynamicClass(object: testObject)
                XCTAssertTrue(false)
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
    
}
