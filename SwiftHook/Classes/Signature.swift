//
//  Signature.swift
//  SwiftHook
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

struct Signature {
    
    enum SignatureType {
        case method
        case closure
    }
    
    let argumentTypes: [String]
    let returnType: String
    let signatureType: SignatureType
    
    private init(argumentTypes: [String], returnType: String, signatureType: SignatureType) {
        self.argumentTypes = argumentTypes
        self.returnType = returnType
        self.signatureType = signatureType
    }
    
    init?(method: Method) {
        guard let methodSignature = SHMethodSignature.init(method: method) else {
            return nil
        }
        self.init(argumentTypes: methodSignature.argumentTypes, returnType: methodSignature.returnType, signatureType: .method)
    }
    
    init?(closure: Any) {
        guard let methodSignature = SHMethodSignature.init(block: closure) else {
            return nil
        }
        self.init(argumentTypes: methodSignature.argumentTypes, returnType: methodSignature.returnType, signatureType: .closure)
    }
    
    static func canHookClosureWorksByMethod(closure: Any, method: Method, mode: HookMode) throws {
        guard let methodSignature = Signature(method: method),
            let closureSignature = Signature(closure: closure) else {
                throw SwiftHookError.missingSignature
        }
        try canHookClosureSignatureWorksByMethodSignature(closureSignature: closureSignature, methodSignature: methodSignature, mode: mode)
    }
    
    static func canHookClosureSignatureWorksByMethodSignature(closureSignature: Signature, methodSignature: Signature, mode: HookMode) throws {
        guard closureSignature.signatureType == .closure else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        guard methodSignature.signatureType == .method else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        guard let emptyClosure = Signature(closure: {} as @convention(block) () -> Void) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        guard closureSignature.argumentTypes[0] == "@?" else {
            throw SwiftHookError.incompatibleClosureSignature
        }
        
        let closureIsMatchMethod = { (closureSignature: Signature, methodSignature: Signature) -> Bool in
            var closureArgumentTypes = closureSignature.argumentTypes
            closureArgumentTypes.removeFirst()
            var methodArgumentTypes = methodSignature.argumentTypes
            methodArgumentTypes.removeFirst(2)
            return closureArgumentTypes == methodArgumentTypes
        }
        
        switch mode {
        case .before:
            guard closureSignature.returnType == emptyClosure.returnType else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            guard closureSignature.argumentTypes == emptyClosure.argumentTypes ||
                closureIsMatchMethod(closureSignature, methodSignature) else {
                    throw SwiftHookError.incompatibleClosureSignature
            }
        case .after:
            guard closureSignature.returnType == emptyClosure.returnType else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            guard closureSignature.argumentTypes == emptyClosure.argumentTypes ||
                closureIsMatchMethod(closureSignature, methodSignature) else {
                    throw SwiftHookError.incompatibleClosureSignature
            }
        case .instead:
            guard closureSignature.returnType == methodSignature.returnType else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            guard closureSignature.argumentTypes.count == methodSignature.argumentTypes.count  else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            guard closureSignature.argumentTypes[1] == "@?" else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            if closureSignature.argumentTypes.count >= 3 {
                for index in 2 ... closureSignature.argumentTypes.count - 1 {
                    guard closureSignature.argumentTypes[index] == methodSignature.argumentTypes[index] else {
                        throw SwiftHookError.incompatibleClosureSignature
                    }
                }
            }
        }
    }
}
