//
//  HookSpecificInstanceTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 26/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import XCTest
import SwiftHook

class HookSpecificInstanceTests: XCTestCase {
    
    // MARK: - empty closure
    
    // before
    func test_before() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod() {
                self.run = true
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        try hookBefore(object: obj, selector: #selector(MyObject.myMethod)) { [weak obj] in
            XCTAssertFalse(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertFalse(obj!.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        obj.myMethod()
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // after
    func test_after() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod(number: Double, url: URL?) -> Double {
                self.run = true
                return number * 3
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        try hookAfter(object: obj, selector: #selector(MyObject.myMethod(number:url:))) { [weak obj] in
            XCTAssertTrue(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(obj!.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        let result = obj.myMethod(number: 3.333, url: nil)
        XCTAssertEqual(result, 9.999)
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // MARK: - self and selector closure
    
    // before
    func test_before_obj_sel() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod(number: Double, url: URL?) -> Double {
                self.run = true
                return number * 3
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        try hookBefore(object: obj, selector: #selector(MyObject.myMethod(number:url:))) {[weak obj] object, sel in
            XCTAssertTrue(obj! === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            
            XCTAssertFalse(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertFalse(obj!.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        let result = obj.myMethod(number: 3.333, url: nil)
        XCTAssertEqual(result, 9.999)
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // after
    func test_after_obj_sel() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod() {
                self.run = true
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        try hookAfter(object: obj, selector: #selector(MyObject.myMethod)) {[weak obj] object, sel in
            XCTAssertTrue(obj! === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            
            XCTAssertTrue(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(obj!.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        obj.myMethod()
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // MARK: - custom closure
    
    // before
    
    func test_before_custom() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod(number: Int, url: URL) -> Int {
                self.run = true
                return number * 2
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        
        try hookBefore(object: obj, selector: #selector(MyObject.myMethod(number:url:)), closure: { [weak obj] object, sel in
            XCTAssertTrue(obj! === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            
            XCTAssertFalse(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertFalse(obj!.run)
            XCTAssertTrue(run)
        } as @convention(block) (NSObject, Selector) -> Void)
        
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        let result = obj.myMethod(number: 77, url: URL.init(string: "https://google.com")!)
        XCTAssertEqual(result, 154)
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // after
    
    func test_after_custom() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod(number: Int, url: URL?) -> URL? {
                self.run = true
                return URL.init(string: "https://facebook.com")
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        
        try hookAfter(object: obj, selector: #selector(MyObject.myMethod(number:url:)), closure: { [weak obj] object, sel, number, url in
            XCTAssertTrue(obj! === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            XCTAssertEqual(number, 77)
            XCTAssertEqual(url, URL.init(string: "https://google.com"))
            
            XCTAssertTrue(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(obj!.run)
            XCTAssertTrue(run)
        } as @convention(block) (NSObject, Selector, Int, URL?) -> Void)
        
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        let result = obj.myMethod(number: 77, url: URL.init(string: "https://google.com")!)
        XCTAssertEqual(result, URL.init(string: "https://facebook.com"))
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // instead
    
    func test_instead_custom() throws {
        class MyObject {
            var run = false
            @objc dynamic func myMethod(number: Int, url: URL?) -> URL? {
                self.run = true
                return URL.init(string: "https://facebook.com")
            }
        }
        
        let obj = MyObject()
        var run = false
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        
        try hookInstead(object: obj, selector: #selector(MyObject.myMethod(number:url:)), closure: { [weak obj] original, object, sel, number, url in
            XCTAssertTrue(obj! === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            XCTAssertEqual(number, 77)
            XCTAssertEqual(url, URL.init(string: "https://google.com"))
            
            XCTAssertFalse(obj!.run)
            XCTAssertFalse(run)
            let result = original(object, sel, number, url)
            XCTAssertEqual(result, URL.init(string: "https://facebook.com"))
            XCTAssertTrue(obj!.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(obj!.run)
            XCTAssertTrue(run)
            return URL.init(string: "https://amazon.com")
        } as @convention(block) ((NSObject, Selector, Int, URL?) -> URL?, NSObject, Selector, Int, URL?) -> URL?)
        
        XCTAssertFalse(obj.run)
        XCTAssertFalse(run)
        let result = obj.myMethod(number: 77, url: URL.init(string: "https://google.com")!)
        XCTAssertEqual(result, URL.init(string: "https://amazon.com"))
        XCTAssertTrue(obj.run)
        XCTAssertTrue(run)
    }
    
    // MARK: before deinit
    
    func test_before_deinit() throws {
        class MyObject: NSObject {
            static var isReleased = false
            deinit {
                MyObject.isReleased = true
            }
        }
        weak var reference: MyObject?
        var run = false
        try autoreleasepool {
            XCTAssertNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            let obj = MyObject()
            reference = obj
            XCTAssertNotNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            try hookDeallocBefore(object: obj) {
                XCTAssertNil(reference)
                XCTAssertEqual(run, false)
                run = true
                XCTAssertNil(reference)
                XCTAssertEqual(run, true)
                XCTAssertFalse(MyObject.isReleased)
            }
        }
        XCTAssertNil(reference)
        XCTAssertEqual(run, true)
        XCTAssertTrue(MyObject.isReleased)
    }
    
    func test_before_deinit_obj() throws {
        class MyObject: NSObject {
            static var isReleased = false
            var name = "aaa"
            deinit {
                MyObject.isReleased = true
            }
        }
        weak var reference: MyObject?
        var run = false
        try autoreleasepool {
            XCTAssertNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            let obj = MyObject()
            obj.name = "bbb"
            reference = obj
            XCTAssertNotNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            try hookDeallocBefore(object: obj) { obj in
                XCTAssertEqual(obj.name, "bbb")
                XCTAssertNil(reference)
                XCTAssertEqual(run, false)
                run = true
                XCTAssertNil(reference)
                XCTAssertEqual(run, true)
                XCTAssertFalse(MyObject.isReleased)
            }
        }
        XCTAssertNil(reference)
        XCTAssertEqual(run, true)
        XCTAssertTrue(MyObject.isReleased)
    }
    
    // MARK: after deinit
    
    func test_after_deinit() throws {
        class MyObject: NSObject {
            static var isReleased = false
            deinit {
                MyObject.isReleased = true
            }
        }
        weak var reference: MyObject?
        var run = false
        try autoreleasepool {
            XCTAssertNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            let obj = MyObject()
            reference = obj
            XCTAssertNotNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            try hookDeallocAfter(object: obj) {
                XCTAssertNil(reference)
                XCTAssertEqual(run, false)
                run = true
                XCTAssertNil(reference)
                XCTAssertEqual(run, true)
                XCTAssertTrue(MyObject.isReleased)
            }
        }
        XCTAssertNil(reference)
        XCTAssertEqual(run, true)
        XCTAssertTrue(MyObject.isReleased)
    }
    
    func test_after_deinit_tail() throws {
        class MyObject: NSObject {
            static var isReleased = false
            deinit {
                MyObject.isReleased = true
            }
        }
        weak var reference: MyObject?
        var run = false
        autoreleasepool {
            XCTAssertNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            let obj = MyObject()
            reference = obj
            XCTAssertNotNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            hookDeallocAfterByTail(object: obj) {
                XCTAssertNil(reference)
                XCTAssertEqual(run, false)
                run = true
                XCTAssertNil(reference)
                XCTAssertEqual(run, true)
                XCTAssertTrue(MyObject.isReleased)
            }
        }
        XCTAssertNil(reference)
        XCTAssertEqual(run, true)
        XCTAssertTrue(MyObject.isReleased)
    }
    
    // MARK: replace deinit
    
    func test_install_deinit() throws {
        class MyObject: NSObject {
            static var isReleased = false
            deinit {
                MyObject.isReleased = true
            }
        }
        weak var reference: MyObject?
        var run = false
        try autoreleasepool {
            XCTAssertNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            let obj = MyObject()
            reference = obj
            XCTAssertNotNil(reference)
            XCTAssertEqual(run, false)
            XCTAssertFalse(MyObject.isReleased)
            try hookDeallocInstead(object: obj, closure: { original in
                XCTAssertNil(reference)
                XCTAssertEqual(run, false)
                XCTAssertFalse(MyObject.isReleased)
                original()
                run = true
                XCTAssertNil(reference)
                XCTAssertEqual(run, true)
                XCTAssertTrue(MyObject.isReleased)
            })
        }
        XCTAssertNil(reference)
        XCTAssertEqual(run, true)
        XCTAssertTrue(MyObject.isReleased)
    }
}
