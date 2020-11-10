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
        
        static let closureTypeValue = (try? TypeValue.init(string: "@?"))!
        static let objectTypeValue = (try? TypeValue.init(string: "@"))!
        static let selectorTypeValue = (try? TypeValue.init(string: ":"))!
        static let voidTypeValue = (try? TypeValue.init(string: "v"))!
        
        init?(string: String) throws {
            guard let nameRange = string.range(of: "^[^\\<]+", options: .regularExpression) else {
                return nil
            }
            // convert "@?<@@?@:q>" to "@?"
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
        
        func internalClosureSignature() throws -> Signature? {
            guard self == .closureTypeValue else {
                return nil
            }
            guard let internalValue = self.internalValue else {
                return nil
            }
            try Signature.checkObjCTypes(types: internalValue)
            guard let methodSignature = SHMethodSignature.init(objCTypes: internalValue) else {
                return nil
            }
            return try Signature.init(methodSignature: methodSignature, signatureType: .closure)
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
    
    private init?(methodSignature: SHMethodSignature, signatureType: SignatureType) throws {
        var argumentTypeValues = [TypeValue]()
        for argumentType in methodSignature.argumentTypes {
            guard let typeValue = try TypeValue.init(string: argumentType) else {
                return nil
            }
            argumentTypeValues.append(typeValue)
        }
        guard let returnTypeValue = try TypeValue.init(string: methodSignature.returnType) else {
            return nil
        }
        self.init(argumentTypes: argumentTypeValues, returnType: returnTypeValue, signatureType: signatureType)
    }
    
    init?(method: Method) throws {
        guard let objCTypes = method_getTypeEncoding(method) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try Signature.checkObjCTypes(types: objCTypes)
        guard let methodSignature = SHMethodSignature.init(objCTypes: objCTypes) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try self.init(methodSignature: methodSignature, signatureType: .method)
    }
    
    init?(closure: AnyObject) throws {
        guard closure.isKind(of: NSClassFromString("NSBlock")!) else {
            return nil
        }
        guard let objCTypes = sh_blockSignature(closure) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try Signature.checkObjCTypes(types: objCTypes)
        guard let methodSignature = SHMethodSignature.init(objCTypes: objCTypes)else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try self.init(methodSignature: methodSignature, signatureType: .closure)
    }
    
    private static func checkObjCTypes(types: UnsafePointer<Int8>) throws {
        let objCTypesString: String = String.init(cString: types)
        guard !objCTypesString.contains("=}") else {
            throw SwiftHookError.emptyStruct
        }
    }
}
