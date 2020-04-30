//
//  Signature.swift
//  SwiftHook
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

struct Signature: Equatable {
    
    let argumentTypes: [String]
    let returnType: String
    
    private init(argumentTypes: [String], returnType: String) {
        self.argumentTypes = argumentTypes
        self.returnType = returnType
    }
    
    init?(class: AnyClass, selector: Selector) {
        guard let method = class_getInstanceMethod(`class`, selector) else {
            return nil
        }
        guard let typeEncoding = method_getTypeEncoding(method) else {
                return nil
        }
        guard let methodSignature = SHMethodSignature.init(objCTypes: typeEncoding) else {
            return nil
        }
        self.init(argumentTypes: methodSignature.argumentsType, returnType: methodSignature.methodReturnType)
    }
    
    init?(closure: Any) {
        guard let methodSignature = SHMethodSignature.init(block: closure) else {
            return nil
        }
        self.init(argumentTypes: methodSignature.argumentsType, returnType: methodSignature.methodReturnType)
    }
}
