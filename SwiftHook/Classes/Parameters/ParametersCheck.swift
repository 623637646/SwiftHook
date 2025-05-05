//
//  ParametersCheck.swift
//  SwiftHook
//
//  Created by Yanni Wang on 17/8/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private let retainSelector = NSSelectorFromString("retain")
private let releaseSelector = NSSelectorFromString("release")
private let autoreleaseSelector = NSSelectorFromString("autorelease")
private let blacklistSelectors = [retainSelector, releaseSelector, autoreleaseSelector]
private let taggedPointerStringClass: AnyClass? = NSClassFromString("NSTaggedPointerString")

// MARK: private

func parametersCheck(for object: AnyObject, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    guard !(object is AnyClass) else {
        throw SwiftHookError.hookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard baseClass != taggedPointerStringClass else {
        throw SwiftHookError.hookInstanceOfNSTaggedPointerString
    }
    try parametersCheck(for: baseClass, selector: selector, mode: mode, closure: closure)
}

func parametersCheck(for targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    guard !blacklistSelectors.contains(selector) else {
        throw SwiftHookError.blacklist
    }
    let isHookingDeallocSelector = selector == deallocSelector
    if isHookingDeallocSelector {
        guard targetClass is NSObject.Type else {
            throw SwiftHookError.pureSwiftObjectDealloc
        }
    }
    
    guard let method = class_getInstanceMethod(targetClass, selector) else {
        throw SwiftHookError.noRespondSelector
    }
    
    let methodSignature = try Signature(method: method)
    
    let closureSignature = try Signature(closure: closure)
    
    guard closureSignature.signatureType == .closure else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    guard methodSignature.signatureType == .method else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    
    let closureReturnType = closureSignature.returnType
    var closureArgumentTypes = closureSignature.argumentTypes
    let methodReturnType = methodSignature.returnType
    let methodArgumentTypes = methodSignature.argumentTypes
    
    guard methodArgumentTypes.count >= 2, closureArgumentTypes.count >= 1 else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    closureArgumentTypes.removeFirst()
    if isHookingDeallocSelector {
        switch mode {
        case .before:
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `before`, the hook closure must return `void`. Found `\(closureReturnType.code)`.")
            }
            guard closureArgumentTypes.isEmpty ||
                    (closureArgumentTypes.count == 1 && closureArgumentTypes.first == .objectTypeValue) else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `before`, the hook closure must have no parameters or a single parameter of type `AnyObject`. Found: `\(closureArgumentTypes.toSignatureString())`.")
            }
        case .after:
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `after`, the hook closure must return `void`. Found `\(closureReturnType.code)`.")
            }
            guard closureArgumentTypes.isEmpty else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `after`, the hook closure must have no parameters. Found: `\(closureArgumentTypes.toSignatureString())`.")
            }
        case .instead:
            // Original closure (first parameter)
            guard closureArgumentTypes.count == 1 else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the hook closure must have exactly one parameter: the original `dealloc` closure. Found \(closureArgumentTypes.count) parameters.")
            }
            let originalClosureType = closureArgumentTypes[0]
            guard originalClosureType == .closureTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the single parameter of the hook closure must be a closure (that represents the original `dealloc` implementation). Found: `\(originalClosureType.code)`.")
            }
            guard let originalClosureSignature = try originalClosureType.internalClosureSignature() else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            closureArgumentTypes.removeFirst()
            
            let originalClosureReturnType = originalClosureSignature.returnType
            var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
            
            guard originalClosureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the original closure (the hook closure`s parameter) must return `void`. Found: `\(originalClosureReturnType.code)`.")
            }
            guard originalClosureArgumentTypes.count >= 1 else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            originalClosureArgumentTypes.removeFirst()
            guard originalClosureArgumentTypes.isEmpty else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the original closure (the hook closure`s parameter) must have no parameters (besides `self`). Found: `\(originalClosureArgumentTypes.toSignatureString())`.")
            }
            
            // Hook closure
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("In `instead` mode for `dealloc`, the hook closure must return `void`. Found: `\(closureReturnType.code)`.")
            }
            guard closureArgumentTypes.isEmpty else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking `dealloc` using `instead`, the hook closure must have no parameters besides the `original` closure parameter. Found: `\(closureArgumentTypes.toSignatureString())`.")
            }
        }
        
    } else {
        switch mode {
        case .before, .after:
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `\(mode.rawValue)`, the hook closure must return `void`. Found: `\(closureReturnType.code)`.")
            }
            guard closureArgumentTypes.isEmpty ||
                    closureArgumentTypes == Array.init(methodArgumentTypes[0..<2]) ||
                    closureArgumentTypes == methodArgumentTypes  else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `\(mode.rawValue)`, the hook closure parameters must be either empty, `(AnyObject, Selector)`, or match the method's parameters. Closure: `\(closureArgumentTypes.toSignatureString())`, Method: `\(methodArgumentTypes.toSignatureString())`.")
            }
        case .instead:
            // Original closure (first parameter)
            guard closureArgumentTypes.count == methodArgumentTypes.count + 1 else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `instead`, the hook closure must have the same number of parameters as the method + one extra parameter: The first parameter is the `original` closure, followed by the parameters of the method. Found \(closureArgumentTypes.count) parameters, expected \(methodArgumentTypes.count + 1).")
            }
            let originalClosureType = closureArgumentTypes[0]
            guard originalClosureType == .closureTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `instead`, the first parameter of the hook closure must be a closure (the `original` closure). Found `\(originalClosureType.code)`.")
            }
            guard let originalClosureSignature = try originalClosureType.internalClosureSignature() else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            closureArgumentTypes.removeFirst()
            
            let originalClosureReturnType = originalClosureSignature.returnType
            var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
            
            guard originalClosureReturnType == methodReturnType else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `instead`, the `original` closure (the hook closure`s first parameter) must return the same type as the method. Original: `\(originalClosureReturnType.code)`, Method: `\(methodReturnType.code)`.")
            }
            guard originalClosureArgumentTypes.count >= 1 else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            originalClosureArgumentTypes.removeFirst()
            guard originalClosureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `instead`, the parameters of the `original` closure (the hook closure`s first parameter) must match the method parameters. Original: `\(originalClosureArgumentTypes.toSignatureString())`, Method: `\(methodArgumentTypes.toSignatureString())`.")
            }
            
            // Hook closure
            guard closureReturnType == methodReturnType else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `instead`, the hook closure must return the same type as the method. Closure: `\(closureReturnType.code)`, Method: `\(methodReturnType.code)`.")
            }
            guard closureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature("When hooking using `instead`, the hook closure’s parameters (after the first `original` closure) must match the method’s parameters. Closure: `\(closureArgumentTypes.toSignatureString())`, Method: `\(methodArgumentTypes.toSignatureString())`.")
            }
        }
    }
}

