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
    
    static func canHookClosureSignatureWorksByMethodSignature(closureSignature: Signature, methodSignature: Signature, mode: HookMode) throws {
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
        methodArgumentTypes.removeFirst(2)
        
        switch mode {
        case .before, .after:
            guard closureReturnType == .voidTypeValue else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            if !closureArgumentTypes.isEmpty {
                switch closureArgumentTypes.count - methodArgumentTypes.count {
                case 0:
                    guard closureArgumentTypes == methodArgumentTypes else {
                        throw SwiftHookError.incompatibleClosureSignature
                    }
//                case 1:
//                    guard closureArgumentTypes[0] == .objectTypeValue || closureArgumentTypes[0] == .selectorTypeValue else {
//                        throw SwiftHookError.incompatibleClosureSignature
//                    }
//                    closureArgumentTypes.removeFirst()
//                    guard closureArgumentTypes == methodArgumentTypes else {
//                        throw SwiftHookError.incompatibleClosureSignature
//                    }
//                case 2:
//                    guard closureArgumentTypes[0] == .objectTypeValue else {
//                        throw SwiftHookError.incompatibleClosureSignature
//                    }
//                    guard closureArgumentTypes[1] == .selectorTypeValue else {
//                        throw SwiftHookError.incompatibleClosureSignature
//                    }
//                    closureArgumentTypes.removeFirst(2)
//                    guard closureArgumentTypes == methodArgumentTypes else {
//                        throw SwiftHookError.incompatibleClosureSignature
//                    }
                default:
                    throw SwiftHookError.incompatibleClosureSignature
                }
            }
        case .instead:
            guard closureReturnType == methodReturnType else {
                throw SwiftHookError.incompatibleClosureSignature
            }
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
            guard originalClosureSignature.returnType == methodReturnType else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            var originalClosureArgumentTypes = originalClosureSignature.argumentTypes
            guard originalClosureArgumentTypes.count - 1 == methodArgumentTypes.count else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            originalClosureArgumentTypes.removeFirst()
            guard originalClosureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature
            }
            closureArgumentTypes.removeFirst()
            guard closureArgumentTypes == methodArgumentTypes else {
                throw SwiftHookError.incompatibleClosureSignature
            }
        }
    }
}
