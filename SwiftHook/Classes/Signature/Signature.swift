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
        
        let code: String
        private let internalValue: String?
        
        static let closureTypeValue = (try? TypeValue.init(string: "@?"))!
        static let objectTypeValue = (try? TypeValue.init(string: "@"))!
        static let selectorTypeValue = (try? TypeValue.init(string: ":"))!
        static let voidTypeValue = (try? TypeValue.init(string: "v"))!
        
        init(string: String) throws {
            guard let nameRange = string.range(of: "^[^\\<]+", options: .regularExpression) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            // convert "@?<@@?@:q>" to "@?"
            self.code = String.init(string[nameRange])
            if let closureSignatureRange = string.range(of: "(?<=\\<).+(?=\\>)", options: .regularExpression) {
                self.internalValue = String.init(string[closureSignatureRange])
            } else {
                self.internalValue = nil
            }
        }
        
        private static let is32BitDevice = Int.bitWidth == Int32.bitWidth
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            let result = lhs.code == rhs.code
            
            /* This code is to fix a system issue.
             The BOOL's signature is "B" normally. But on 32-bit device. BOOL's signature is "c" https://stackoverflow.com/a/26621855/9315497
             It's fine if both closure and method's signature are "c" for BOOL.
             But there is a bug between Swift and 32 bit device. https://stackoverflow.com/q/65519942/9315497
             The signature of BOOL in a swift closure is "B" on 32-bit device! This is different from "c" in method.
             So here will be wrong.
             */
            if is32BitDevice, result == false {
                if (lhs.code == "c" && rhs.code == "B") || (lhs.code == "B" && rhs.code == "c") {
                    return true
                }
            }
            return result
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
    
    private init(methodSignature: SHMethodSignature, signatureType: SignatureType) throws {
        var argumentTypeValues = [TypeValue]()
        for argumentType in methodSignature.argumentTypes {
            let typeValue = try TypeValue.init(string: argumentType)
            argumentTypeValues.append(typeValue)
        }
        let returnTypeValue = try TypeValue.init(string: methodSignature.returnType)
        self.init(argumentTypes: argumentTypeValues, returnType: returnTypeValue, signatureType: signatureType)
    }
    
    init(method: Method) throws {
        guard let objCTypes = method_getTypeEncoding(method) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try Signature.checkObjCTypes(types: objCTypes)
        guard let methodSignature = SHMethodSignature.init(objCTypes: objCTypes) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try self.init(methodSignature: methodSignature, signatureType: .method)
    }
    
    init(closure: AnyObject) throws {
        guard closure.isKind(of: NSClassFromString("NSBlock")!) else {
            throw SwiftHookError.wrongTypeForHookClosure
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

extension Array where Element == Signature.TypeValue {
    func toSignatureString() -> String {
        self.map {$0.code}.joined()
    }
}
