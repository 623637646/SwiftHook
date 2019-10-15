//
//  Lock.swift
//  iOSHook
//
//  Created by Yanni Wang on 15/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import Foundation

// lock
var lock = os_unfair_lock()
func performLocked(block: () -> Void) -> Void {
    os_unfair_lock_lock(&lock)
    block()
    os_unfair_lock_unlock(&lock)
}
