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

    func testInstancesDoNotRespondSelector() {
        do {
            try TestObject.hookBefore(selector: #selector(NSArray.object(at:)), block: {})
            XCTAssertTrue(false)
        } catch SwiftHookError.instancesDoNotRespondSelector(let `class`, let selector) {
            XCTAssertTrue(`class` == TestObject.self)
            XCTAssertEqual(selector, #selector(NSArray.object(at:)))
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func testTemp() {
        
    }

}
