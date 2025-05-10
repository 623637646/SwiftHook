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
}

func getHookClosures(object: AnyObject, selector: Selector) -> (before: [AnyObject], after: [AnyObject], instead: [AnyObject]) {
    guard let context = closuresContext(for: object) else {
        return ([], [], [])
    }
    return (context.before[selector] ?? [], context.after[selector] ?? [], context.instead[selector] ?? [])
}

func appendHookClosure(object: AnyObject, selector: Selector, hookClosure: AnyObject, mode: HookMode) throws {
    let context = getAssociatedValue("closuresContext", object: object, initialValue: ClosuresContext())
    switch mode {
    case .before:
        var closures = context.before[selector] ?? []
        guard !closures.contains(where: {
            hookClosure  === $0
        }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.append(hookClosure)
        context.before[selector] = closures
    case .after:
        var closures = context.after[selector] ?? []
        guard !closures.contains(where: {
            hookClosure  === $0
        }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.append(hookClosure)
        context.after[selector] = closures
    case .instead:
        var closures = context.instead[selector] ?? []
        guard !closures.contains(where: {
            hookClosure  === $0
        }) else {
            throw SwiftHookError.duplicateHookClosure
        }
        closures.append(hookClosure)
        context.instead[selector] = closures
    }
}

func removeHookClosure(object: AnyObject, selector: Selector, hookClosure: AnyObject, mode: HookMode) throws {
    guard let context = closuresContext(for: object) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    switch mode {
    case .before:
        var closures = context.before[selector] ?? []
        guard closures.contains(where: {
            hookClosure  === $0
        }) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        closures.removeAll {
            hookClosure  === $0
        }
        context.before[selector] = closures
    case .after:
        var closures = context.after[selector] ?? []
        guard closures.contains(where: {
            hookClosure  === $0
        }) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        closures.removeAll {
            hookClosure  === $0
        }
        context.after[selector] = closures
    case .instead:
        var closures = context.instead[selector] ?? []
        guard closures.contains(where: {
            hookClosure  === $0
        }) else {
            throw SwiftHookError.internalError(file: #file, line: #line)
        }
        closures.removeAll {
            hookClosure  === $0
        }
        context.instead[selector] = closures
    }
}

func isHookClosuresEmpty(object: AnyObject) -> Bool {
    guard let context = closuresContext(for: object) else {
        return true
    }
    for (_, value) in context.before where !value.isEmpty {
        return false
    }
    for (_, value) in context.instead where !value.isEmpty {
        return false
    }
    for (_, value) in context.after where !value.isEmpty {
        return false
    }
    return true
}

// MARK: This is debug tools.

func debug_hookClosureCount(object: AnyObject) -> Int {
    guard let context = closuresContext(for: object) else {
        return 0
    }
    var count = 0
    for (_, value) in context.before where !value.isEmpty {
        count += value.count
    }
    for (_, value) in context.instead where !value.isEmpty {
        count += value.count
    }
    for (_, value) in context.after where !value.isEmpty {
        count += value.count
    }
    return count
}

private func closuresContext(for object: AnyObject) -> ClosuresContext? {
    getAssociatedValue("closuresContext", object: object)
}
