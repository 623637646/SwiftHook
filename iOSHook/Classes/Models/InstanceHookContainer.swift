//
//  Models.swift
//  iOSHook
//
//  Created by Yanni Wang on 15/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

struct InstanceHookContainer {
    var obj: NSObject? {
        get {
            return self.objWeakBlock()
        }
    }
    let selector: Selector
    let onlyOnce: Bool
    
    private var objWeakBlock: (()-> NSObject?)
    
    init(obj: NSObject, selector: Selector, onlyOnce: Bool = false) {
        self.selector = selector
        self.onlyOnce = onlyOnce
        self.objWeakBlock = {[weak obj] in
            return obj
        }
    }
}
