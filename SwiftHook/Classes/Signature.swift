//
//  Signature.swift
//  SwiftHook
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

struct Signature {
    
    let argumentTypes: [String]
    let returnType: String
    
    private init(argumentTypes: [String], returnType: String) {
        self.argumentTypes = argumentTypes
        self.returnType = returnType
    }
    
    // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    private init?(typeEncoding: UnsafePointer<Int8>) {
        guard let methodSignature = SHMethodSignature.init(objCTypes: typeEncoding) else {
            return nil
        }
        self.init(argumentTypes: methodSignature.argumentsType, returnType: methodSignature.methodReturnType)
    }
    
    init?(method: Method) {
        guard let typeEncodingPointer = method_getTypeEncoding(method) else {
                return nil
        }
        self.init(typeEncoding: typeEncodingPointer)
    }
    
    init?(class: AnyClass, selector: Selector) {
        guard let method = class_getInstanceMethod(`class`, selector) else {
            return nil
        }
        self.init(method: method)
    }
    
    //    init(closure: AnyObject) {
    //
    //    }
}
