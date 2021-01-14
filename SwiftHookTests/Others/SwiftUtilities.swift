//
//  SwiftUtilities.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 14/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//
@testable import SwiftHook

// MARK: Random

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

// MARK: ClassType

private let dynamicClassPrefix = "SwiftHook_"
private let kvoPrefix = "NSKVONotifying_"

enum ClassType: Equatable {
    
    enum KVOedMode {
        case normal
        case swiftHook
    }
    
    case normal
    case dynamic
    case KVOed(mode: KVOedMode)
    case others
}

func testGetObjectType(object: AnyObject) throws -> ClassType {
    // normal
    if try testIsNormal(object: object) {
        guard try !testIsDynamic(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard try !testIsKVOed(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard try !testIsKVOedWithSwiftHook(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return .normal
    } else if try testIsDynamic(object: object) {
        // dynamic
        guard try !testIsNormal(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard try !testIsKVOed(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard try !testIsKVOedWithSwiftHook(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return .dynamic
    } else if try testIsKVOed(object: object) {
        // kvo
        guard try !testIsNormal(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard try !testIsDynamic(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return .KVOed(mode: try testIsKVOedWithSwiftHook(object: object) ? .swiftHook : .normal)
    } else {
        return .others
    }
}

private func testIsNormal(object: AnyObject) throws -> Bool {
    let isaClass: AnyClass = object_getClass(object)!
    let typeClass: AnyClass = type(of: object)
    guard typeClass == sht_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return isaClass == typeClass
}

private func testIsKVOed(object: AnyObject) throws -> Bool {
    let isaClass: AnyClass = object_getClass(object)!
    let typeClass: AnyClass = type(of: object)
    guard typeClass == sht_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    let className = NSStringFromClass(isaClass)
    if className.hasPrefix(kvoPrefix) {
        guard let object = object as? NSObject else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard !observationInfoIsNil(object: object) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        var currentClass: AnyClass = isaClass
        var hit = false
        while let superClass = class_getSuperclass(currentClass) {
            if superClass == typeClass {
                hit = true
                break
            } else {
                currentClass = superClass
            }
        }
        guard hit else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard className.replacingOccurrences(of: kvoPrefix, with: "") == NSStringFromClass(class_getSuperclass(isaClass)!) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return true
    } else {
        return false
    }
}

private func testIsKVOedWithSwiftHook(object: AnyObject) throws -> Bool {
    guard try testIsKVOed(object: object) else {
        return false
    }
    guard let object = object as? NSObject else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return isWrappedKVO(object: object)
}

private func testIsDynamic(object: AnyObject) throws -> Bool {
    let isaClass: AnyClass = object_getClass(object)!
    let typeClass: AnyClass = type(of: object)
    guard typeClass == sht_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    let className = NSStringFromClass(isaClass)
    if className.hasPrefix(dynamicClassPrefix) {
        guard isDynamicClass(targetClass: isaClass) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard class_getSuperclass(isaClass) == typeClass else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard className.replacingOccurrences(of: dynamicClassPrefix, with: "") == "\(ObjectIdentifier(typeClass).hashValue)" else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard !(object is NSObject) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return true
    } else {
        guard !isDynamicClass(targetClass: isaClass) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return false
    }
}

private func observationInfoIsNil(object: NSObject) -> Bool {
    guard let observationInfo = object.observationInfo else {
        return true
    }
    return unsafeBitCast(observationInfo, to: AnyObject?.self) == nil
}
