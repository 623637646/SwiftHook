//
//  Signature.swift
//  SwiftHook
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

struct Types: Equatable {
    let typeName: String
    let length: UInt
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.typeName == rhs.typeName && lhs.length == rhs.length
    }
}

struct Signature {
    
    let argumentTypes:[Types]
    let returnType: Types
    
    private init(argumentTypes: [Types], returnType: Types) {
        self.argumentTypes = argumentTypes
        self.returnType = returnType
    }
    
    private init(typeEncoding: String) {
        // TODO: 
        self.init(argumentTypes: [], returnType: Types.init(typeName: "", length: 11))
    }
    
    init?(method: Method) {
        guard let typeEncodingPointer = method_getTypeEncoding(method),
            let typeEncoding = String.init(utf8String: typeEncodingPointer) else {
                return nil
        }
        self.init(typeEncoding: typeEncoding)
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
