//
//  AssociatedHookClosure.swift
//  SwiftHook
//
//  Created by Yanni Wang on 18/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

private var associatedBeforeHandle: UInt8 = 0
private var associatedInsteadHandle: UInt8 = 0
private var associatedAfterHandle: UInt8 = 0

private func associatedGetAllClosures(object: AnyObject, mode: HookMode) -> [Selector: [AnyObject]] {
    switch mode {
    case .before:
        return objc_getAssociatedObject(object, &associatedBeforeHandle) as? [Selector: [AnyObject]] ?? [:]
    case .after:
        return objc_getAssociatedObject(object, &associatedAfterHandle) as? [Selector: [AnyObject]] ?? [:]
    case .instead:
        return objc_getAssociatedObject(object, &associatedInsteadHandle) as? [Selector: [AnyObject]] ?? [:]
    }
}

private func associatedSetAllClosures(object: AnyObject, mode: HookMode, allClosures: [Selector: [AnyObject]]) {
    switch mode {
    case .before:
        objc_setAssociatedObject(object, &associatedBeforeHandle, allClosures, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    case .after:
        objc_setAssociatedObject(object, &associatedAfterHandle, allClosures, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    case .instead:
        objc_setAssociatedObject(object, &associatedInsteadHandle, allClosures, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

func associatedGetClosures(object: AnyObject, selector: Selector, mode: HookMode) -> [AnyObject] {
    return associatedGetAllClosures(object: object, mode: mode)[selector] ?? []
}

func associatedSetClosures(object: AnyObject, selector: Selector, mode: HookMode, closures: [AnyObject]) {
    var allClosures = associatedGetAllClosures(object: object, mode: mode)
    allClosures[selector] = closures
    associatedSetAllClosures(object: object, mode: mode, allClosures: allClosures)
}

func associatedAppendClosure(object: AnyObject, selector: Selector, hookClosure: AnyObject, mode: HookMode) throws {
    var closures = associatedGetClosures(object: object, selector: selector, mode: mode)
    guard !closures.contains(where: {
        hookClosure  === $0
    }) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    closures.append(hookClosure)
    associatedSetClosures(object: object, selector: selector, mode: mode, closures: closures)
}

func associatedRemoveClosure(object: AnyObject, selector: Selector, hookClosure: AnyObject, mode: HookMode) throws {
    var closures = associatedGetClosures(object: object, selector: selector, mode: mode)
    guard closures.contains(where: {
        return hookClosure === $0
    }) else {
        throw SwiftHookError.internalError(file: #file, line: #line)
    }
    closures.removeAll {
        hookClosure  === $0
    }
    associatedSetClosures(object: object, selector: selector, mode: mode, closures: closures)
}

func associatedHasNonClosures(object: AnyObject) -> Bool {
    let before = associatedGetAllClosures(object: object, mode: .before)
    let instead = associatedGetAllClosures(object: object, mode: .instead)
    let after = associatedGetAllClosures(object: object, mode: .after)
    for (_, value) in before where !value.isEmpty {
        return false
    }
    for (_, value) in instead where !value.isEmpty {
        return false
    }
    for (_, value) in after where !value.isEmpty {
        return false
    }
    return true
}

// MARK: This is debug tools.
#if DEBUG
func debug_associatedClosureCount(object: AnyObject) -> Int {
    let before = associatedGetAllClosures(object: object, mode: .before)
    let instead = associatedGetAllClosures(object: object, mode: .instead)
    let after = associatedGetAllClosures(object: object, mode: .after)
    var count = 0
    for (_, value) in before where !value.isEmpty {
        count += value.count
    }
    for (_, value) in instead where !value.isEmpty {
        count += value.count
    }
    for (_, value) in after where !value.isEmpty {
        count += value.count
    }
    return count
}
#endif
