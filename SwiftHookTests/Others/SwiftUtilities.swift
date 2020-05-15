//
//  SwiftUtilities.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 14/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

func isNotDynamicClass(object: AnyObject) -> Bool {
    let typeClass: AnyClass = type(of: object)
    let isaClass: AnyClass = object_getClass(object)!
    let objectiveCClass: AnyClass = sht_getClass(object)!
    return isaClass == typeClass && objectiveCClass == typeClass
}

func isDynamicClass(object: AnyObject) -> Bool {
    let typeClass: AnyClass = type(of: object)
    let isaClass: AnyClass = object_getClass(object)!
    let objectiveCClass: AnyClass = sht_getClass(object)!
    return isaClass != typeClass &&
        class_getSuperclass(isaClass)! == typeClass &&
    objectiveCClass == typeClass
}

// TODO: is KVO Class
