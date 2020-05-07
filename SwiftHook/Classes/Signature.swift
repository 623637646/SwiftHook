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
        self.init(argumentTypes: methodSignature.argumentTypes, returnType: methodSignature.methodReturnType, signatureType: .method)
    }
    
    init?(closure: Any) {
        guard let methodSignature = SHMethodSignature.init(block: closure) else {
            return nil
        }
        self.init(argumentTypes: methodSignature.argumentTypes, returnType: methodSignature.methodReturnType, signatureType: .closure)
    }
    
    func isMatch(other: Signature) -> Bool {
        guard self.returnType == other.returnType else {
            return false
        }
        let selfBusinessArgumentTypes: [String]
        switch self.signatureType {
        case .method:
            var argumentTypes = self.argumentTypes
            argumentTypes.removeFirst(2)
            selfBusinessArgumentTypes = argumentTypes
        case .closure:
            var argumentTypes = self.argumentTypes
            argumentTypes.removeFirst()
            selfBusinessArgumentTypes = argumentTypes
        }
        let otherBusinessArgumentTypes: [String]
        switch other.signatureType {
        case .method:
            var argumentTypes = other.argumentTypes
            argumentTypes.removeFirst(2)
            otherBusinessArgumentTypes = argumentTypes
        case .closure:
            var argumentTypes = other.argumentTypes
            argumentTypes.removeFirst()
            otherBusinessArgumentTypes = argumentTypes
        }
        return selfBusinessArgumentTypes == otherBusinessArgumentTypes
    }
}
