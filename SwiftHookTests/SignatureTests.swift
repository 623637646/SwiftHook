//
//  SignatureTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SignatureTests: XCTestCase {

    func testExample() {
        let signature = Signature.init(class: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc))
        XCTAssertNotNil(signature)
        XCTAssertEqual(signature!.argumentTypes, [])
    }

}
