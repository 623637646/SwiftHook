//
//  Signature.swift
//  SwiftHook
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

struct Signature {
    
    struct TypeValue: Equatable {
        let name: String
        private let internalValue: String?
        var internalClosureSignature: Signature? {
            guard self == .closureTypeValue else {
                return nil
            }
            guard let internalValue = self.internalValue else {
                return nil
            }
            guard let methodSignature = SHMethodSignature.init(string: internalValue) else {
                return nil
            }
            return Signature.init(methodSignature: methodSignature, signatureType: .closure)
        }
        
        static let closureTypeValue = TypeValue.init(string: "@?")!
        static let objectTypeValue = TypeValue.init(string: "@")!
        static let selectorTypeValue = TypeValue.init(string: ":")!
        static let voidTypeValue = TypeValue.init(string: "v")!
        
        init?(string: String) {
            guard let nameRange = string.range(of: "^[^\\<]+", options: .regularExpression) else {
                return nil
            }
            var name = String.init(string[nameRange])
            // Remove "const". Refer to: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
            // TODO: test others cases for this.
            if name.first == "r" {
                name.removeFirst()
            }
            self.name = name
            if let closureSignatureRange = string.range(of: "(?<=\\<).+(?=\\>)", options: .regularExpression) {
                self.internalValue = String.init(string[closureSignatureRange])
            } else {
                self.internalValue = nil
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    enum SignatureType {
        case method
        case closure
    }
    
    let argumentTypes: [TypeValue]
    let returnType: TypeValue
    let signatureType: SignatureType
    
    init(argumentTypes: [TypeValue], returnType: TypeValue, signatureType: SignatureType) {
        self.argumentTypes = argumentTypes
        self.returnType = returnType
        self.signatureType = signatureType
    }
    
    private init?(methodSignature: SHMethodSignature, signatureType: SignatureType) {
        var argumentTypeValues = [TypeValue]()
        for argumentType in methodSignature.argumentTypes {
            guard let typeValue = TypeValue.init(string: argumentType) else {
                return nil
            }
            argumentTypeValues.append(typeValue)
        }
        guard let returnTypeValue = TypeValue.init(string: methodSignature.returnType) else {
            return nil
        }
        self.init(argumentTypes: argumentTypeValues, returnType: returnTypeValue, signatureType: signatureType)
    }
    
    init?(method: Method) {
        guard let methodSignature = SHMethodSignature.init(method: method) else {
            return nil
        }
        self.init(methodSignature: methodSignature, signatureType: .method)
    }
    
    init?(closure: AnyObject) {
        guard let methodSignature = SHMethodSignature.init(block: closure) else {
            return nil
        }
        self.init(methodSignature: methodSignature, signatureType: .closure)
    }
}
