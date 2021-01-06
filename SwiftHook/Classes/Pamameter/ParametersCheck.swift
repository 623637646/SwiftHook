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

// MARK: private

func parametersCheck(object: AnyObject, selector: Selector, mode: HookMode, closure: AnyObject) throws {
    guard !(object is AnyClass) else {
        throw SwiftHookError.hookClassWithObjectAPI
    }
    guard let baseClass = object_getClass(object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    try parametersCheck(targetClass: baseClass, selector: selector, mode: mode, closure: closure)
}

func parametersCheck(targetClass: AnyClass, selector: Selector, mode: HookMode, closure: AnyObject) throws {
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
        case .before, .after:
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `befor` and `after` mode. The return type of the hook closure mush be `v`. But it's `\(closureReturnType.code)`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard closureArgumentTypes.isEmpty else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `befor` and `after` mode. The parameters of the hook closure mush be empty. But it's `\(closureArgumentTypes.toSignatureString())`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
        case .instead:
            // Original closure (first parameter)
            guard closureArgumentTypes.count == 1 else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `instead` mode. The number of hook closure parameters should be 1 (The parameter is the `original` closure). But now it's \(closureArgumentTypes.count).")
            }
            let originalClosureType = closureArgumentTypes[0]
            guard originalClosureType == .closureTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The type of the hook closure's first parameter should be a closure (It's `original` closure). But the signature is `\(originalClosureType.code)`. By right it should be \"@?\". For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard let originalClosureSignature = try originalClosureType.internalClosureSignature() else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            closureArgumentTypes.removeFirst()
            
            let originalClosureReturnType = originalClosureSignature.returnType
            var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
            
            guard originalClosureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `instead` mode. The return type of the original closure (the hook closure's first parameter) should be `v`. But the return type of the original closure is `\(originalClosureReturnType.code)`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard originalClosureArgumentTypes.count >= 1 else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            originalClosureArgumentTypes.removeFirst()
            guard originalClosureArgumentTypes.isEmpty else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `instead` mode. The parameters of the original closure (the hook closure's first parameter) must be empty. The original closure parameters type is `\(originalClosureArgumentTypes.toSignatureString())`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            
            // Hook closure
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `instead` mode. The return type of the hook closure should be `v`. But the return type of the hook closure is `\(closureReturnType.code)`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard closureArgumentTypes.isEmpty else {
                throw SwiftHookError.incompatibleClosureSignature(description: "Hook \"dealloc\" method for `instead` mode. The parameters of the hook closure without firt one (The first parameter is the `original` closure) must be empty. But now the parameters type of the hook closure without firt one is `\(closureArgumentTypes.toSignatureString())`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
        }
        
    } else {
        switch mode {
        case .before, .after:
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `befor` and `after` mode. The return type of the hook closure mush be `v`. But it's `\(closureReturnType.code)`. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            if !closureArgumentTypes.isEmpty {
                guard closureArgumentTypes == methodArgumentTypes else {
                    throw SwiftHookError.incompatibleClosureSignature(description: "For `befor` and `after` mode. The parameters type of the hook closure must be the same as method's. The closure parameters type is `\(closureArgumentTypes.toSignatureString())`. But the method parameters type is `\(methodArgumentTypes.toSignatureString())`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
                }
            }
        case .instead:
            // Original closure (first parameter)
            guard closureArgumentTypes.count == methodArgumentTypes.count + 1 else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The number of hook closure parameters should be equal to the number of method parameters + 1 (The first parameter is the `original` closure. The rest is the same as method's). The hook closure parameters number is \(closureArgumentTypes.count). The method parameters number is \(methodArgumentTypes.count).")
            }
            let originalClosureType = closureArgumentTypes[0]
            guard originalClosureType == .closureTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The type of the hook closure's first parameter should be a closure (It's `original` closure). But the signature is `\(originalClosureType.code)`. By right it should be \"@?\". For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard let originalClosureSignature = try originalClosureType.internalClosureSignature() else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            closureArgumentTypes.removeFirst()
            
            let originalClosureReturnType = originalClosureSignature.returnType
            var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
            
            guard originalClosureReturnType == methodReturnType else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The return type of the original closure (the hook closure's first parameter) should be the same as method's return type. But the return type of the original closure is `\(originalClosureReturnType.code)`, The return type of the method is `\(methodReturnType.code)`. Thay are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard originalClosureArgumentTypes.count >= 1 else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            originalClosureArgumentTypes.removeFirst()
            guard originalClosureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The parameters type of the original closure (the hook closure's first parameter) must be the same as the method's. The original closure parameters type is `\(originalClosureArgumentTypes.toSignatureString())`. But the method parameters type is `\(methodArgumentTypes.toSignatureString())`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            
            // Hook closure
            guard closureReturnType == methodReturnType else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The return type of the hook closure should be the same as method's return type. But the return type of the hook closure is `\(closureReturnType.code)`, The return type of the method is `\(methodReturnType.code)`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
            guard closureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature(description: "For `instead` mode. The parameters type of the hook closure without firt one (The first parameter is the `original` closure) must be the same as the method's. But now the parameters type of the hook closure without firt one is `\(closureArgumentTypes.toSignatureString())`. But the method parameters type is `\(methodArgumentTypes.toSignatureString())`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
            }
        }
    }
}
