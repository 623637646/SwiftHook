//
//  SwiftUtilities.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 14/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//
@testable import SwiftHook

// MARK: utilities

func randomTestObject() -> AnyObject {
    if Int.random(in: 0 ... 1) == 0 {
        return ObjectiveCTestObject()
    } else {
        return TestObject()
    }
}

func randomTestClass() -> AnyClass {
    if Int.random(in: 0 ... 1) == 0 {
        return ObjectiveCTestObject.self
    } else {
        return TestObject.self
    }
}

func randomSelector() -> Selector {
    switch Int.random(in: 0 ... 2) {
    case 0:
        return #selector(TestObject.noArgsNoReturnFunc)
    case 1:
        return #selector(TestObject.sumFunc(a:b:))
    default:
        return #selector(TestObject.testSimpleSignature(char:int:swiftInt:short:long:longlong:unsignedChar:unsignedInt:swiftUnsignedInt:unsignedshort:unsignedLong:unsignedLongLong:float:swiftFloat:double:swiftDouble:bool:swiftBool:characterString:object:class:selector:))
    }
}

func randomMode() -> HookMode {
    switch Int.random(in: 0 ... 2) {
    case 0:
        return .before
    case 1:
        return .after
    default:
        return .instead
    }
}

func testIsDynamicClass(object: AnyObject) throws -> Bool {
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

#if DEBUG
func debug_cleanUp() {
    debug_cleanUpHookContextPool()
    debug_cleanUpDynamicClassContextPool()
}
#endif
