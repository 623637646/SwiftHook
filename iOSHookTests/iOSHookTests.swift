//
//  InstanceBeforeTests.swift
//  iOSHookTests
//
//  Created by Yanni Wang on 14/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

import XCTest
import iOSHook

class TestObject: NSObject {
    @objc dynamic func simple() {
        
    }
}

class InstanceBeforeTests: XCTestCase {
    func testHook() {
        do {
            let before = try getMemory()
            for _ in 0...1000000 {
                try TestObject.hook(selector: #selector(TestObject.simple),
                                                signature: (nil, nil),
                                                block: { (original, args: Void) -> Void in
                                                    return original(args)
                            })
                //            TestObject().simple()
            }
            let after = try getMemory()
            let diff = Double(after - before)/1024/1024
            print("Memory cast \(diff)M")
            XCTAssertLessThan(diff, 0.5)
        } catch {
            print("error: %@", error)
            XCTAssertTrue(false)
        }
    }
    
    func getMemory() throws -> UInt64 {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return taskInfo.resident_size
        }
        else {
            throw NSError.init()
        }
    }
}
