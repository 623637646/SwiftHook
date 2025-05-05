//
//  AssociatedHookClosure.swift
//  SwiftHook
//
//  Created by Yanni Wang on 18/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private class ClosuresContext {
    var before: [Selector: [AnyObject]] = [:]
    var after: [Selector: [AnyObject]] = [:]
    var instead: [Selector: [AnyObject]] = [:]
    
    var isEmpty: Bool {
        [before, instead, after].allSatisfy { $0.values.allSatisfy(\.isEmpty) }
    }
    
    var count: Int {
        [before, instead, after].flatMap { $0.values }.reduce(0) { $0 + $1.count }
    }
}

func hookClosures(for object: AnyObject, selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
    guard let context = closuresContext(for: object) else {
        return ([], [], [])
    }
    return (context.before[selector] ?? [], context.after[selector] ?? [], context.instead[selector] ?? [])
}

func appendHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, to object: AnyObject) throws {
    let context = getAssociatedValue("associatedContextHandle", object: object, initialValue: ClosuresContext())
    
    func append(to dictKeyPath: ReferenceWritableKeyPath<ClosuresContext, [Selector: [AnyObject]]>) throws {
        var closures = context[keyPath: dictKeyPath][selector] ?? []
        guard !closures.contains(where: { hookClosure === $0 }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.append(hookClosure)
        context[keyPath: dictKeyPath][selector] = closures
    }

    switch mode {
    case .before:
        try append(to: \.before)
    case .after:
        try append(to: \.after)
    case .instead:
        try append(to: \.instead)
    }
}

func removeHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, for object: AnyObject) throws {
    guard let context = closuresContext(for: object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    switch mode {
    case .before:
        context.before[selector]?.removeAll(where: { hookClosure === $0 })
    case .after:
        context.after[selector]?.removeAll(where: { hookClosure === $0 })
    case .instead:
        context.instead[selector]?.removeAll(where: { hookClosure === $0 })
    }
}

func isHookClosuresEmpty(for object: AnyObject) -> Bool {
    closuresContext(for: object)?.isEmpty ?? true
}

func hookClosureCount(for object: AnyObject) -> Int {
    closuresContext(for: object)?.count ?? 0
}

fileprivate func closuresContext(for object: AnyObject) -> ClosuresContext? {
    getAssociatedValue("associatedContextHandle", object: object)
}
