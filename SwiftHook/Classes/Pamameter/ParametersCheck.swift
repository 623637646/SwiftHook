//
//  ParametersCheck.swift
//  SwiftHook
//
//  Created by Yanni Wang on 17/8/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private let KVOPrefix = "NSKVONotifying_"

private let retainSelector = NSSelectorFromString("retain")
private let releaseSelector = NSSelectorFromString("release")
private let autoreleaseSelector = NSSelectorFromString("autorelease")
private let blacklistSelectors = [retainSelector, releaseSelector, autoreleaseSelector]

// MARK: private

// TODO: when hook dealloc, Can't get the default objc parameter.
// TODO: test case: hook before dealloc, strong retain object!
func parametersCheck(object: AnyObject, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    guard !(object is AnyClass) else {
        throw SwiftHookError.canNotHookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: mode, closure: closure)
}

func parametersCheck(targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    guard !blacklistSelectors.contains(selector) else {
        throw SwiftHookError.unsupport(value: .blacklist)
    }
    let isHookingDeallocSelector = selector == deallocSelector
    if isHookingDeallocSelector {
        guard targetClass is NSObject.Type else {
            throw SwiftHookError.unsupport(value: .pureSwiftObjectDealloc)
        }
    }
    guard !NSStringFromClass(targetClass).hasPrefix(KVOPrefix) else {
        throw SwiftHookError.unsupport(value: .KVOedObject)
    }
    
    guard let method = class_getInstanceMethod(targetClass, selector) else {
        throw SwiftHookError.noRespondSelector
    }
    
    guard let methodSignature = Signature(method: method),
        let closureSignature = Signature(closure: closure) else {
            throw SwiftHookError.missingSignature
    }
    
    guard closureSignature.signatureType == .closure else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard methodSignature.signatureType == .method else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    
    let closureReturnType = closureSignature.returnType
    var closureArgumentTypes = closureSignature.argumentTypes
    let methodReturnType = methodSignature.returnType
    var methodArgumentTypes = methodSignature.argumentTypes
    
    guard methodArgumentTypes.count >= 2, closureArgumentTypes.count >= 1 else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    closureArgumentTypes.removeFirst()
    if isHookingDeallocSelector {
        methodArgumentTypes.removeFirst(2)
    }
    
    switch mode {
    case .before, .after:
        guard closureReturnType == .voidTypeValue else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        if !closureArgumentTypes.isEmpty {
            guard closureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature
            }
        }
    case .instead:
        // original closure (first parameter)
        guard closureArgumentTypes.count == methodArgumentTypes.count + 1 else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        let originalClosureType = closureArgumentTypes[0]
        guard originalClosureType == .closureTypeValue else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        guard let originalClosureSignature = originalClosureType.internalClosureSignature else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        closureArgumentTypes.removeFirst()
        
        let originalClosureReturnType = originalClosureSignature.returnType
        var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
        
        guard originalClosureReturnType == closureReturnType else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        guard originalClosureArgumentTypes.count >= 1 else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        originalClosureArgumentTypes.removeFirst()
        guard originalClosureArgumentTypes == closureArgumentTypes else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        
        // external closure (the outside closure)
        guard closureReturnType == methodReturnType else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        guard closureArgumentTypes == methodArgumentTypes else {
            throw SwiftHookError.incompatibleClosureSignature
        }
    }
}
