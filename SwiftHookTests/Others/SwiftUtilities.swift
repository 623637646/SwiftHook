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
private let KVOPrefix = "NSKVONotifying_"

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
    let isNormal = try testIsNormal(object: object)
    let isDynamic = try testIsDynamic(object: object)
    let isIsKVOed = try testIsKVOed(object: object)
    let isKVOedWithSwiftHook = try testIsKVOedWithSwiftHook(object: object)
    if isNormal && !isDynamic && !isIsKVOed && !isKVOedWithSwiftHook {
        return .normal
    } else if !isNormal && isDynamic && !isIsKVOed && !isKVOedWithSwiftHook {
        return .dynamic
    } else if !isNormal && !isDynamic && isIsKVOed && !isKVOedWithSwiftHook {
        return .KVOed(mode: .normal)
    } else if !isNormal && !isDynamic && isIsKVOed && isKVOedWithSwiftHook {
        return .KVOed(mode: .swiftHook)
    } else if !isNormal && !isDynamic && !isIsKVOed && !isKVOedWithSwiftHook {
        return .others
    } else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
}

private func testIsNormal(object: AnyObject) throws -> Bool {
    let (isaClass, typeClass): (AnyClass, AnyClass) = try getClasses(object: object)
    return isaClass == typeClass
}

private func testIsKVOed(object: AnyObject) throws -> Bool {
    let (isaClass, typeClass): (AnyClass, AnyClass) = try getClasses(object: object)
    guard isaClass != typeClass else {
        return false
    }
    let className = NSStringFromClass(isaClass)
    guard let object = object as? NSObject else {
        guard !className.hasPrefix(KVOPrefix) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        return false
    }
    let hasKVOPrefix = className.hasPrefix(KVOPrefix)
    let nameMatchAfterRemovingKVOPrefix = { () -> Bool in
        if let range = className.range(of: KVOPrefix),
              className.replacingCharacters(in: range, with: "") == NSStringFromClass(class_getSuperclass(isaClass)!) {
            return true
        } else {
            return false
        }
    }()
    let hit = { () -> Bool in
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
        return hit
    }()
    let isKVOedFromAPI = try isKVOed(object: object)
    if isKVOedFromAPI && hasKVOPrefix && hit && nameMatchAfterRemovingKVOPrefix {
        return true
    } else if !hasKVOPrefix && !nameMatchAfterRemovingKVOPrefix {
        return false
    } else {
        throw SwiftHookError.internalError(file: #file, line: #line)
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
    let (isaClass, typeClass): (AnyClass, AnyClass) = try getClasses(object: object)
    let className = NSStringFromClass(isaClass)
    let isDynamic = isDynamicClass(targetClass: isaClass)
    let hasDynamicClassPrefix = className.hasPrefix(dynamicClassPrefix)
    let isSuperClassMatch = class_getSuperclass(isaClass) == typeClass
    let isNameMatch = className.replacingOccurrences(of: dynamicClassPrefix, with: "") == "\(ObjectIdentifier(typeClass).hashValue)"
    if isDynamic && hasDynamicClassPrefix && isSuperClassMatch && isNameMatch {
        return true
    } else if !isDynamic && !isNameMatch {
        return false
    } else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
}

// Some special cases, when some objects be removed all observers, the class is still NSKVONotifying_XXX and the observationInfo is nil.
//private func observationInfoIsNil(object: NSObject) -> Bool {
//    guard let observationInfo = object.observationInfo else {
//        return true
//    }
//    return unsafeBitCast(observationInfo, to: AnyObject?.self) == nil
//}

private func getClasses(object: AnyObject) throws -> (isaClass: AnyClass, typeClass: AnyClass) {
    let isaClass: AnyClass = object_getClass(object)!
    let typeClass: AnyClass = type(of: object)
    guard typeClass == sht_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    return (isaClass: isaClass, typeClass: typeClass)
}

@objcMembers class SwiftUtilitiesOCAPI: NSObject {
    class func getObjectType(object: NSObject) -> String {
        switch try! testGetObjectType(object: object) {
        case .normal:
            return "normal"
        case .dynamic:
            return "dynamic"
        case .KVOed(mode: let mode):
            switch mode {
            case .normal:
                return "KVOed_normal"
            case .swiftHook:
                return "KVOed_swiftHook"
            }
        case .others:
            return "others"
        }
    }
    
    class func isSupportedKVOWithObject(_ object: NSObject) -> Bool {
        return try! isSupportedKVO(object: object)
    }
    
    class func overrideMethodContextCount() -> Int {
        return debug_overrideMethodContextCount()
    }
}
