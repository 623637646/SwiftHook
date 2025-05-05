//
//  InsteadHookClosureExtension.swift
//  SwiftHook
//
//  Created by Yanni Wang on 26/8/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import SwiftHookOCSources
#endif

class InsteadContext {
    let objectPointer: UnsafeMutableRawPointer
    let selectorPointer: UnsafeMutableRawPointer
    var currentHookClosure: AnyObject
    
    init(objectPointer: UnsafeMutableRawPointer, selectorPointer: UnsafeMutableRawPointer, currentHookClosure: AnyObject) {
        self.objectPointer = objectPointer
        self.selectorPointer = selectorPointer
        self.currentHookClosure = currentHookClosure
    }
}

func createInsteadClosure(targetIMP: IMP, objectPointer: UnsafeMutableRawPointer, selectorPointer: UnsafeMutableRawPointer, currentHookClosure: AnyObject) -> AnyObject {
    let insteadClosure: (@convention(block) () -> Void) = { }
    sh_setBlockInvoke(insteadClosure, targetIMP)
    let insteadContext = InsteadContext(objectPointer: objectPointer, selectorPointer: selectorPointer, currentHookClosure: currentHookClosure)
    setAssociatedValue(insteadContext, key: "associatedInsteadContextHandle", object: insteadClosure as AnyObject)
    return insteadClosure as AnyObject
}

func getInsteadContext(insteadClosure: AnyObject) -> InsteadContext? {
    getAssociatedValue("associatedInsteadContextHandle", object: insteadClosure)
}
