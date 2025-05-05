//
//  Signature.swift
//  SwiftHook
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import SwiftHookOCSources
#endif

struct Signature {
    
    struct TypeValue: Equatable {
        
        let code: String
        private let internalValue: String?
        private let isOriginalClosure: Bool
        
        static let closureTypeValue = (try? TypeValue(string: "@?"))!
        static let objectTypeValue = (try? TypeValue(string: "@"))!
        static let selectorTypeValue = (try? TypeValue(string: ":"))!
        static let voidTypeValue = (try? TypeValue(string: "v"))!
        
        private static let is32BitDevice = Int.bitWidth == Int32.bitWidth
        
        init(string: String, isOriginalClosure: Bool = false) throws {
            self.isOriginalClosure = isOriginalClosure
            guard let nameRange = string.range(of: "^[^\\<]+", options: .regularExpression) else {
                throw SwiftHookError.internalError(file: #file, line: #line)
            }
            // convert "@?<@@?@:q>" to "@?"
            var code = String(string[nameRange])
            
            if Signature.TypeValue.is32BitDevice && code == "B" {
                /* This code is to fix a system issue.
                 The BOOL's signature is "B" normally. But on 32-bit device. BOOL's signature is "c" https://stackoverflow.com/a/26621855/9315497
                 It's fine if both closure and method's signature are "c" for BOOL.
                 But there is a bug between Swift and 32 bit device. https://stackoverflow.com/q/65519942/9315497
                 The signature of BOOL in a swift closure is "B" on 32-bit device! This is different from "c" in method.
                 So here will be wrong.
                 Note: Only "B" will be converted to "c". "r^B", "{MyStruct=B}" and so on are not.
                 */
                code = "c"
            }
            self.code = code
            
            if let closureSignatureRange = string.range(of: "(?<=\\<).+(?=\\>)", options: .regularExpression) {
                self.internalValue = String(string[closureSignatureRange])
            } else {
                self.internalValue = nil
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            var lshCode = lhs.code
            var rhsCode = rhs.code
            if lhs.isOriginalClosure,
               rhsCode.first == "r" {
                rhsCode.removeFirst()
            }
            if rhs.isOriginalClosure,
               lshCode.first == "r" {
                lshCode.removeFirst()
            }
            return lshCode == rhsCode
        }
        
        func internalClosureSignature() throws -> Signature? {
            guard self == .closureTypeValue else {
                return nil
            }
            guard let internalValue = self.internalValue else {
                return nil
            }
            try Signature.checkObjCTypes(types: internalValue)
            guard let methodSignature = SHMethodSignature(objCTypes: internalValue) else {
                return nil
            }
            return try Signature(methodSignature: methodSignature, signatureType: .originalClosure)
        }
    }
    
    enum SignatureType {
        case method
        case closure
        case originalClosure
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
            let typeValue = try TypeValue(string: argumentType, isOriginalClosure: signatureType == .originalClosure)
            argumentTypeValues.append(typeValue)
        }
        let returnTypeValue = try TypeValue(string: methodSignature.returnType, isOriginalClosure: signatureType == .originalClosure)
        self.init(argumentTypes: argumentTypeValues, returnType: returnTypeValue, signatureType: signatureType)
    }
    
    init(method: Method) throws {
        guard let objCTypes = method_getTypeEncoding(method) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try Signature.checkObjCTypes(types: objCTypes)
        guard let methodSignature = SHMethodSignature(objCTypes: objCTypes) else {
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
        guard let methodSignature = SHMethodSignature(objCTypes: objCTypes)else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        try self.init(methodSignature: methodSignature, signatureType: .closure)
    }
    
    private static func checkObjCTypes(types: UnsafePointer<Int8>) throws {
        guard !String(cString: types).contains("=}") else {
            throw SwiftHookError.emptyStruct
        }
    }
}

extension Array where Element == Signature.TypeValue {
    func toSignatureString() -> String {
        self.map {$0.code}.joined()
    }
}
