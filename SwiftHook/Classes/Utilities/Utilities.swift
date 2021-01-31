//
//  Utilities.swift
//  SwiftHook
//
//  Created by Yanni Wang on 7/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

func getMethodWithoutSearchingSuperClasses(targetClass: AnyClass, selector: Selector) -> Method? {
    var length: UInt32 = 0
    let firstMethod = withUnsafeMutablePointer(to: &length) { (p) -> UnsafeMutablePointer<Method>? in
        class_copyMethodList(targetClass, p)
    }
    defer {
        free(firstMethod)
    }
    let bufferPointer = UnsafeBufferPointer.init(start: firstMethod, count: Int(length))
    for method in bufferPointer {
        if method_getName(method) == selector {
            return method
        }
    }
    return nil
}

#if DEBUG
func debug_printAllMethodAndIMP(targetClass: AnyClass) {
    var length: UInt32 = 0
    let firstMethod = withUnsafeMutablePointer(to: &length) { (p) -> UnsafeMutablePointer<Method>? in
        class_copyMethodList(targetClass, p)
    }
    defer {
        free(firstMethod)
    }
    let bufferPointer = UnsafeBufferPointer.init(start: firstMethod, count: Int(length))
    for method in bufferPointer {
        print("name: \(NSStringFromSelector(method_getName(method))), IMP: \(method_getImplementation(method))")
    }
}
#endif
