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
    
    func closures(for selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
        (before[selector] ?? [], after[selector] ?? [], instead[selector] ?? [])
    }
}

func hookClosures(for object: AnyObject, selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
    closuresContext(for: object)?.closures(for: selector) ?? ([], [], [])
}

func appendHookClosure(_ hookClosure: AnyObject, selector: Selector, mode: HookMode, to object: AnyObject) throws {
    var context = getAssociatedValue("closuresContext", object: object, initialValue: ClosuresContext())
    
    func append(to keyPath: WritableKeyPath<ClosuresContext, [Selector: [AnyObject]]>) throws {
        var closures = context[keyPath: keyPath][selector] ?? []
        guard !closures.contains(where: { hookClosure === $0 }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.append(hookClosure)
        context[keyPath: keyPath][selector] = closures
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
    guard var context = closuresContext(for: object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    
    func remove(_ keyPath: WritableKeyPath<ClosuresContext, [Selector: [AnyObject]]>) throws {
        var closures = context[keyPath: keyPath][selector] ?? []
        guard closures.contains(where: { hookClosure === $0 }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.removeAll(where: { hookClosure === $0 })
        context[keyPath: keyPath][selector] = closures
    }
    
    switch mode {
    case .before:
        try remove(\.before)
    case .after:
        try remove(\.after)
    case .instead:
        try remove(\.instead)
    }
}

func isHookClosuresEmpty(for object: AnyObject) -> Bool {
    closuresContext(for: object)?.isEmpty ?? true
}

func hookClosureCount(for object: AnyObject) -> Int {
    closuresContext(for: object)?.count ?? 0
}

fileprivate func closuresContext(for object: AnyObject) -> ClosuresContext? {
    getAssociatedValue("closuresContext", object: object)
}
