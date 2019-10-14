//
//  TestObject.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 14/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import UIKit

class TestObject: SuperTestObject {
    
    @objc override func simpleMethod() {
        
    }
    
    @objc func executedBlock(_ block: ()->()) {
        
    }
    
    @objc func returnParameter(_ value: Any) -> Any {
        return value
    }
    
    @objc class func classSimpleMethod() {
        
    }
}
