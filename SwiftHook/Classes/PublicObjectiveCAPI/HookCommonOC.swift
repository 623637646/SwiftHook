//
//  HookCommonOC.swift
//  SwiftHook
//
//  Created by Yanni Wang on 25/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

// MARK: - Token

@objcMembers public class OCToken: NSObject {
    private let token: Token
    init(token: Token) {
        self.token = token
    }
    public func cancelHook() {
        token.cancelHook()
    }
}

extension SwiftHookError {
    var getNSError: NSError {
        let code: Int
        let description: String
        switch self {
        case .hookClassWithObjectAPI:
            code = 0
            description = "Can't hook class with object hooking API. Please use \"hookClassMethod\" instead."
        case .blacklist:
            code = 1
            description = "Unsupport to hook current method. Search \"blacklistSelectors\" to see all methods unsupport."
        case .pureSwiftObjectDealloc:
            code = 2
            description = "Technologically can't hook dealloc method for pure Swift Object with swizzling. Please use \"hookDeallocAfterByTail\" to hook pure swift object's dealloc method."
        case .noRespondSelector:
            code = 3
            description = "Can't find the method by the selector from the class."
        case .emptyStruct:
            code = 4
            description = "The struct of the method's args or return value is empty, This case can't be compatible  with libffi. Please check the parameters or return type of the method."
        case .wrongTypeForHookClosure:
            code = 5
            description = "Please check the hook clousre. Is it a standard closure? Does it have keyword @convention(block)?"
        case .incompatibleClosureSignature(description: let des):
            code = 6
            description = des
        case .duplicateHookClosure:
            code = 7
            description = "This closure has been hooked with current mode already."
        case .ffiError:
            code = 8
            description = "The error from FFI. Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new"
        case .internalError(file: let file, line: let line):
            code = 9
            description = "internalError => file: \(file), line: \(line). Please raise aa issue: https://github.com/623637646/SwiftHook/issues/new"
        case .hookInstanceOfNSTaggedPointerString:
            code = 10
            description = "Unsupport to hook instance of NSTaggedPointerString."
        case .hookKVOUnsupportedInstance:
            code = 11
            description = "Unable to hook a instance which is not support KVO."
        }
        return NSError.init(domain: "SwiftHook.SwiftHookError", code: code, userInfo: [NSLocalizedDescriptionKey: description])
        
    }
}
