//
//  AssociatedValue.swift
//  SwiftHook
//
//  Created by Florian Zand on 05.05.25.
//

import Foundation

func getAssociatedValue<T>(_ key: String, object: AnyObject) -> T? {
    objc_getAssociatedObject(object, key.address) as? T
}

func getAssociatedValue<T>(_ key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    getAssociatedValue(key, object: object) ?? setAndReturn(initialValue(), key: key, object: object)
}

func setAssociatedValue<T>(_ value: T?, key: String, object: AnyObject) {
    objc_setAssociatedObject(object, key.address, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private func setAndReturn<T>(_ value: T, key: String, object: AnyObject) -> T {
    objc_setAssociatedObject(object, key.address, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return value
}

fileprivate extension String {
    var address: UnsafeRawPointer {
        UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}
