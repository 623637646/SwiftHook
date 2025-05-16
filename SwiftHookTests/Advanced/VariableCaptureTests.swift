//
//  VariableCaptureTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 29/9/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
import SwiftHook

class VariableCaptureTests: XCTestCase {

    func test_Int() throws {
        class MyObject {
            @objc dynamic func double(number: Int) -> Int {
                return number * 2
            }
        }
        
        let object = MyObject()
        let addNumber = 3
        let token = try ObjectHook(object).hook(#selector(MyObject.double(number:)), closure: {original, o, s, number in
            let result = original(o, s, number)
            XCTAssertEqual(result, 22)
            return result + addNumber
        } as @convention(block) ((AnyObject, Selector, Int) -> Int, AnyObject, Selector, Int) -> Int)
        XCTAssertEqual(object.double(number: 11), 25)
        token.cancelHook()
    }

}
