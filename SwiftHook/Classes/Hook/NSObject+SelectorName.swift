//
//  NSObject+SelectorName.swift
//
//
//  Created by Florian Zand on 06.05.25.
//

import Foundation

extension PartialKeyPath {
    func getterName() throws -> String where Root: AnyObject {
        guard let getterName = _kvcKeyPathString else {
            throw SwiftHookError.nonObjcProperty
        }
        return getterName
    }
    
    func setterName() throws -> String where Root: AnyObject {
        guard let setterName = NSObject.setterName(for: try getterName(), _class: Root.self) else {
            throw SwiftHookError.nonObjcProperty
        }
        return setterName
    }
    
    func getterName<T>() throws -> String where Root == T.Type, T: AnyObject {
        guard let getterName = _kvcKeyPathString else {
            throw SwiftHookError.nonObjcProperty
        }
        return getterName
    }
    
    func setterName<T>() throws -> String where Root == T.Type, T: AnyObject {
        guard let setterName = NSObject.setterName(for: try getterName(), _class: T.self) else {
            throw SwiftHookError.nonObjcProperty
        }
        return setterName
    }
}

fileprivate extension NSObject {
    static func setterName(for getterName: String, _class: AnyClass) -> String? {
        var names: [String] = []
        if getterName.hasPrefix("is") {
            names.append("set\(getterName.dropFirst(2).uppercasedFirst()):")
        } else if getterName.hasPrefix("get") {
            names.append("set\(getterName.dropFirst(3).uppercasedFirst()):")
        }
        names.append("set\(getterName.uppercasedFirst()):")
        for name in names {
            if class_respondsToSelector(_class, NSSelectorFromString(name)) {
                return name
            }
        }
        
        let getterSelector = Selector(getterName)
        var currentClass: AnyClass? = _class
        while let c = currentClass {
            var propertyCount: UInt32 = 0
            guard let properties = class_copyPropertyList(c, &propertyCount) else {
                currentClass = class_getSuperclass(c)
                continue
            }
            defer { free(properties) }
            
            for i in 0..<propertyCount {
                let property = properties[Int(i)]
                let nameCStr = property_getName(property)
                let propName = String(cString: nameCStr)
                
                let getterSel: Selector
                if let getterAttr = property.attribute(for: "G") {
                    getterSel = Selector(getterAttr)
                } else {
                    getterSel = Selector(propName)
                }
                
                if getterSel == getterSelector {
                    if let setterAttr = property.attribute(for: "S") {
                        return setterAttr
                    } else {
                        return "set\(propName.uppercasedFirst()):"
                    }
                }
            }
            currentClass = class_getSuperclass(c)
        }
        return nil
    }
}

fileprivate extension objc_property_t {
    func attribute(for key: String) -> String? {
        var count: UInt32 = 0
        guard let attrs = property_copyAttributeList(self, &count) else { return nil }
        defer { free(attrs) }
        for i in 0..<count {
            let attr = attrs[Int(i)]
            if String(cString: attr.name) == key {
                return String(cString: attr.value)
            }
        }
        return nil
    }
}


fileprivate extension StringProtocol {
    func uppercasedFirst() -> String {
        if isEmpty { return String(self) }
        return prefix(1).uppercased() + dropFirst()
    }
}
