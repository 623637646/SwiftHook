//
//  HookToken.swift
//  SwiftHook
//
//  Created by Florian Zand on 05.05.25.
//

import Foundation

/// Hooking mode.
public enum HookMode: String {
    /// Before.
    case before
    /// After.
    case after
    /// Instead.
    case instead
}

public class HookToken {
    private weak var object: AnyObject?
    private let `class`: AnyClass?
    private let hookClosure: AnyObject
    private weak var hookContext: HookContext?
    private var deallocAfterHook: DeallocAfterHook?
    
    /// The hooking mode.
    public let mode: HookMode
    
    /// The selector of the hook.
    public let selector: Selector
    
    /// A Boolean value indicating whether the hook is active.
    public var isActive: Bool {
        get {
            if let deallocAfterHook = deallocAfterHook {
                return deallocAfterHook.isActive
            }
            return hookContext != nil
        }
        set {
            guard newValue != isActive else { return }
            if newValue {
                try? apply()
            } else {
                revert()
            }
        }
    }
    
    /// Applies the hook.
    public func apply() throws {
        guard !isActive else { return }
        if let deallocAfterHook = deallocAfterHook {
            deallocAfterHook.apply()
        } else if let class_ = `class` {
            let hookContext = try HookContext.get(for: class_, selector: selector, isSpecifiedInstance: false)
            try hookContext.append(hookClosure: hookClosure, mode: mode)
            self.hookContext = hookContext
        } else if let object = object {
            let targetClass: AnyClass
            if let object = object as? NSObject {
                guard try object.isSupportedKVO() else {
                    throw SwiftHookError.hookKVOUnsupportedInstance
                }
                // use KVO for specified instance hook
                try object.wrapKVOIfNeeded(selector: selector)
                guard let KVOedClass = object_getClass(object) else {
                    throw SwiftHookError.internalError(file: #file, line: #line)
                }
                targetClass = KVOedClass
            } else {
                // create dynamic class for specified instance hook
                guard let baseClass = object_getClass(object) else {
                    throw SwiftHookError.internalError(file: #file, line: #line)
                }
                targetClass = isDynamicClass(targetClass: baseClass) ? baseClass : try wrapDynamicClass(object: object)
            }
            // hook
            let hookContext = try HookContext.get(for: targetClass, selector: selector, isSpecifiedInstance: true)
            // set hook closure
            try appendHookClosure(hookClosure, selector: selector, mode: mode, to: object)
            self.hookContext = hookContext
        }
    }
    
    /// Reverts the hook.
    public func revert() {
        guard isActive else { return }
        if let deallocAfterHook = deallocAfterHook {
            deallocAfterHook.revert()
        } else {
            swiftHookSerialQueue.sync {
                _ = try? cancel()
                hookContext = nil
            }
        }
    }
    
    func _apply() throws -> HookToken {
        try apply()
        return self
    }
    
    private func cancel() throws -> Bool? {
        guard let hookContext = hookContext else {
            // This token has been cancelled.
            return nil
        }
        if hookContext.isSpecifiedInstance {
            // This hook is for specified instance
            guard let hookObject = object else {
                // The object has been deinit.
                return nil
            }
            try removeHookClosure(hookClosure, selector: hookContext.selector, mode: mode, for: hookObject)
          //  try removeHookClosure(hookClosure, selector: hookContext.selector, mode: mode, of: hookObject)
            
            guard object_getClass(hookObject) == hookContext.targetClass else {
                // The class is changed after hooking by SwiftHook.
                return false
            }
            guard !(try hookContext.isIMPChanged()) else {
                // The IMP is changed after hooking by SwiftHook.
                return false
            }
            
            guard isHookClosuresEmpty(for: hookObject) else {
                // There are still some hooks on this object.
                return false
            }
            if let object = hookObject as? NSObject {
                object.unwrapKVOIfNeeded()
            } else {
                try unwrapDynamicClass(object: hookObject)
            }
            // Can't call `hookContext.remove()` to remove the hookContext because we don't know if there are any objects needed this hookContext
            return true
        } else {
            // This hook is for all instance or class method
            try hookContext.remove(hookClosure: hookClosure, mode: mode)
            guard !(try hookContext.isIMPChanged()) else {
                // The IMP is changed after hooking by SwiftHook.
                return false
            }
            guard hookContext.isHoolClosurePoolEmpty() else {
                // There are still some hooks on this hookContext.
                return false
            }
            hookContext.remove()
            return true
        }
    }
    
    init(for object: AnyObject, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try parametersCheck(for: object, selector: selector, mode: mode, closure: hookClosure)
        self.mode = mode
        self.hookClosure = hookClosure
        self.selector = selector
        self.object = object
        self.class = nil
    }
    
    init(for class_: AnyClass, selector: Selector, mode: HookMode, hookClosure: AnyObject) throws {
        try parametersCheck(for: class_, selector: selector, mode: mode, closure: hookClosure)
        self.mode = mode
        self.selector = selector
        self.class = class_
        self.hookClosure = hookClosure
    }
    
    init(deallocAfter object: AnyObject, hookClosure: AnyObject) {
        self.mode = .after
        self.hookClosure = hookClosure
        self.selector = deallocSelector
        self.class = nil
        self.deallocAfterHook = .init(object: object, closure: hookClosure)
    }
}

extension HookToken {
    class DeallocAfterHook {
        private  weak var delegate: HookDeallocAfterDelegate?
        private weak var object: AnyObject?
        private let closure: AnyObject
                
        var isActive: Bool = false
        
        func apply() {
            guard !isActive, let object = object else { return }
            let delegate = getAssociatedValue("associatedDelegateHandle", object: object, initialValue: HookDeallocAfterDelegate())
            delegate.hookClosures.append(closure)
            self.delegate = delegate
            isActive = true
        }
        
        func revert() {
            guard isActive else { return }
            delegate?.hookClosures.removeAll(where: { $0 === self.closure })
            isActive = false
        }
        
        init(object: AnyObject, closure: AnyObject) {
            self.object = object
            self.closure = closure
        }
        
        class HookDeallocAfterDelegate {
            var hookClosures = [AnyObject]()
            
            deinit {
                for item in hookClosures.reversed() {
                    unsafeBitCast(item, to: (@convention(block) () -> Void).self)()
                }
            }
        }
    }
}

/*
extension SwiftHook {
    @discardableResult
    public static func hookInstead<MethodSignature, HookSignature> (
        _ selector: Selector, object: AnyObject,
        methodSignature: MethodSignature.Type = MethodSignature.self,
        hookSignature: HookSignature.Type = HookSignature.self,
        _ implementation: (TypedHookAlt<MethodSignature>) -> HookSignature?) throws -> HookToken {
            guard let method = class_getInstanceMethod(object_getClass(object), selector) else {
                 throw NSError(domain: "HookError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Method not found"])
             }
             let imp = method_getImplementation(method)
             let original: MethodSignature = unsafeBitCast(imp, to: MethodSignature.self)
            let typedHook = TypedHookAlt(original: original)

            /*
            guard let hook = implementation(typedHook) else {
                throw NSError(domain: "HookError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Method not Asdsdssddfound"])
            }
            
            let blockObject = unsafeBitCast(hook, to: AnyObject.self)
            */
           // let blockObject = unsafeBitCast(implementation as AnyObject, to: AnyObject.self)

            return try HookToken(for: object, selector: selector, mode: .instead, hookClosure: implementation as AnyObject)._apply()
            
          //  try? TypedHook(object: object, selector: selector, implementation: implementation)
        }
}

public struct TypedHookAlt<MethodSignature> {
    public let original: MethodSignature
}


public class TypedHook<MethodSignature, HookSignature> {
    var origIMP: IMP?
    var replacementIMP: IMP!
    public let `class`: AnyClass
    public let selector: Selector
    
    public var original: MethodSignature {
        // If we switched implementations, return stored.
        if let savedOrigIMP = origIMP {
            return unsafeBitCast(savedOrigIMP, to: MethodSignature.self)
        }
        // Else, perform a dynamic lookup
        guard let origIMP = lookupOrigIMP else {
            preconditionFailure("IMP must be found for call")
        }
        return origIMP
    }
    
    private var lookupOrigIMP: MethodSignature? {
        var currentClass: AnyClass? = self.class
        repeat {
            if let currentClass = currentClass,
                let method = class_getInstanceMethod(currentClass, self.selector) {
                let origIMP = method_getImplementation(method)
                return unsafeBitCast(origIMP, to: MethodSignature.self)
            }
            currentClass = class_getSuperclass(currentClass)
        } while currentClass != nil
        return nil
    }
    
    init(object: AnyObject, selector: Selector, implementation: (TypedHook<MethodSignature, HookSignature>) -> HookSignature?) throws {
        self.class =  type(of: object)
        self.selector = selector
        let block = implementation(self) as AnyObject
        replacementIMP = imp_implementationWithBlock(block)
        guard replacementIMP != nil else {
            throw SwiftHookError.wrongTypeForHookClosure
        }
    }
}
*/
