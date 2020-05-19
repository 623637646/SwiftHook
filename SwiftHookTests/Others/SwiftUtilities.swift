//
//  SwiftUtilities.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 14/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//
@testable import SwiftHook

// TODO: 重命名为 testIsDynamicClass(object
func isDynamicClass(object: AnyObject) throws -> Bool {
    let isaClass: AnyClass = object_getClass(object)!
    let typeClass: AnyClass = type(of: object)
    guard typeClass == sht_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard NSStringFromClass(isaClass).hasPrefix("SwiftHook_") else {
        return false
    }
    guard class_getSuperclass(isaClass) == typeClass else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard NSStringFromClass(isaClass) == "SwiftHook_\(typeClass)" else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return true
}

// TODO: is KVO Class
