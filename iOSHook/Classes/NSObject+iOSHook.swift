//
//  NSObjectExtension.swift
//  iOSHook
//
//  Created by Yanni Wang on 2/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation
import libffi

public enum iOSHookError: Error {
    case canNotFindMethod(class:AnyClass, selector: Selector)
}

public extension NSObject {
    @discardableResult
    class func hook<Return, ArgsTuple>(selector: Selector,
                                       signature:(UInt?, [UInt]?),
                                       block: (_ original: (_ args: ArgsTuple) -> Return, _ args: ArgsTuple) -> Return) throws -> Token? {
        var cif: ffi_cif = ffi_cif()
        let argumentTypes: UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>> = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>>.allocate(capacity: 2)
        argumentTypes[0] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
        argumentTypes[1] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
        ffi_prep_cif(withUnsafeMutablePointer(to: &cif) {$0},
                     FFI_DEFAULT_ABI,
                     2,
                     withUnsafeMutablePointer(to: &ffi_type_pointer) {$0},
                     unsafeBitCast(argumentTypes.baseAddress, to: UnsafeMutablePointer<UnsafeMutablePointer<ffi_type>?>?.self))
        
        
        var obj = self.init()
        let imp = obj.method(for: selector)
        var returnValue: Any? = nil
        let arguments: UnsafeMutableBufferPointer<UnsafeMutablePointer<Any>> = UnsafeMutableBufferPointer<UnsafeMutablePointer<Any>>.allocate(capacity: 2)
        arguments[0] = withUnsafeMutablePointer(to: &obj, { p -> UnsafeMutablePointer<Any> in
            let a = p.withMemoryRebound(to: UnsafeMutablePointer<Any>.self, capacity: 1) { (p2) -> UnsafeMutablePointer<Any> in
                let p3 = p2
                return p3.pointee
            }
            return a
        })
        var selectorTemp = selector
        arguments[1] = withUnsafeMutablePointer(to: &selectorTemp, { p -> UnsafeMutablePointer<Any> in
            let a = p.withMemoryRebound(to: UnsafeMutablePointer<Any>.self, capacity: 1) { (p2) -> UnsafeMutablePointer<Any> in
                let p3 = p2
                return p3.pointee
            }
            return a
        })
        ffi_call(withUnsafeMutablePointer(to: &cif) {$0},
                 unsafeBitCast(imp, to: (@convention(c) () -> Void)?.self),
                 UnsafeMutableRawPointer.init(withUnsafeMutablePointer(to: &returnValue, {$0})),
                 unsafeBitCast(arguments.baseAddress, to: UnsafeMutablePointer<UnsafeMutableRawPointer?>?.self))
        
   
        argumentTypes.deallocate()
        arguments.deallocate()

        
        
        var token: Token? = nil

//        try DispatchQueue(label: "com.iOSHook.sync").sync {
//            guard let method = class_getInstanceMethod(self, selector) else {
//                throw iOSHookError.canNotFindMethod(class: self, selector: selector)
//            }
//
//            let originalIMP = method_getImplementation(method)
//            //            let newIMPBlock: @convention(block) (Self, Int, Double, String) -> Void = {`self`, i, d, s in
//            //                typealias MyCFunction = @convention(c) (AnyObject, Selector, Int, Double, String) -> Void
//            //                let curriedImplementation = unsafeBitCast(originalIMP, to: MyCFunction.self)
//            //                curriedImplementation(self, selector, i, d, s)
//            //            }
//
//            let newIMPBlock = iOSHookImplementationBlock(block, originalIMP, selector)
//            let newIMP = imp_implementationWithBlock(newIMPBlock)
//            let methodType = method_getTypeEncoding(method);
//
//            let addedNewMethod = class_replaceMethod(self, selector, newIMP, methodType) == nil
//
//
//            token = Token()
//        }
        return token
    }
}
