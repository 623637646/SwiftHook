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

// unsafeBitCast 和 withMemoryRebound区别？
// withMemoryRebound 参数的含义
// https://developer.apple.com/documentation/swift/unsafepointer/2430863-withmemoryrebound : Only use this method to rebind the pointer’s memory to a type with the same size and stride as the currently bound Pointee type. To bind a region of memory to a type that is a different size, convert the pointer to a raw pointer and use the bindMemory(to:capacity:) method
public extension NSObject {
    @discardableResult
    class func hook<Return, ArgsTuple>(selector: Selector,
                                       signature:(UInt?, [UInt]?),
                                       block: (_ original: (_ args: ArgsTuple) -> Return, _ args: ArgsTuple) -> Return) throws -> Token? {
        var cif: ffi_cif = ffi_cif()
        
        let argumentTypes = UnsafeMutableBufferPointer<UnsafeMutablePointer<ffi_type>>.allocate(capacity: 2)
        argumentTypes[0] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
        argumentTypes[1] = withUnsafeMutablePointer(to: &ffi_type_pointer, {$0})
        
        ffi_prep_cif(withUnsafeMutablePointer(to: &cif) {$0},
                     FFI_DEFAULT_ABI,
                     2,
                     withUnsafeMutablePointer(to: &ffi_type_pointer) {$0},
                     unsafeBitCast(argumentTypes.baseAddress, to: UnsafeMutablePointer<UnsafeMutablePointer<ffi_type>?>?.self))
        
        
        var obj = self.init()
        let imp = obj.method(for: selector)
        var selectorTemp = selector
        var returnValue: Any? = nil
        let arguments = UnsafeMutableBufferPointer<UnsafeMutablePointer<Any>>.allocate(capacity: 2)
        arguments[0] = withUnsafeMutablePointer(to: &obj, { $0.withMemoryRebound(to: Any.self, capacity: 1, {$0})})
        arguments[1] = withUnsafeMutablePointer(to: &selectorTemp, { $0.withMemoryRebound(to: Any.self, capacity: 1, {$0})})
        
        ffi_call(withUnsafeMutablePointer(to: &cif) {$0},
                 unsafeBitCast(imp, to: (@convention(c) () -> Void)?.self),
                 withUnsafeMutablePointer(to: &returnValue){$0},
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
