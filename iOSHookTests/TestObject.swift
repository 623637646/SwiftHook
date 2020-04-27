//
//  TestObject.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 24/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import UIKit

class TestObject: NSObject {
    @objc dynamic func noArgsNoReturnFunc() {
        
    }
    
    @objc dynamic func sumFunc(a: Int, b: Int) -> Int {
        return a + b
    }
}
