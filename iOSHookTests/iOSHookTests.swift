//
//  InstanceBeforeTests.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 14/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import XCTest
import iOSHook

class InstanceBeforeTests: XCTestCase {
    
    func testInstancesDoNotRespondSelector() {
        do {
            try TestObject.hookBefore(selector: #selector(NSArray.object(at:)), block: {})
            XCTAssertTrue(false)
        } catch iOSHookError.instancesDoNotRespondSelector(let `class`, let `selector`) {
            XCTAssertTrue(`class` == TestObject.self)
            XCTAssertEqual(`selector`, #selector(NSArray.object(at:)))
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    func testTemp() {
        
    }
}
