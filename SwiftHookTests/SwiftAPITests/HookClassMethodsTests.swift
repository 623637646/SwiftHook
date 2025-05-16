//
//  HookClassMethodsTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 26/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

import XCTest
import SwiftHook

class HookClassMethodsTests: XCTestCase {

    // MARK: - empty closure
    
    // before
    func test_before() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod() {
                self.run = true
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        try hookClassMethodBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) {
            XCTAssertFalse(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertFalse(MyObject.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        MyObject.myMethod()
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }
    
    // after
    func test_after() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod(number: Double, url: URL?) -> Double {
                self.run = true
                return number * 3
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        try hookClassMethodAfter(targetClass: MyObject.self, selector: #selector(MyObject.myMethod(number:url:))) {
            XCTAssertTrue(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(MyObject.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        let result = MyObject.myMethod(number: 3.333, url: nil)
        XCTAssertEqual(result, 9.999)
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }
    
    // MARK: - self and selector closure
    
    // before
    func test_before_obj_sel() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod(number: Double, url: URL?) -> Double {
                self.run = true
                return number * 3
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        try hookClassMethodBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod(number:url:))) { object, sel in
            XCTAssertTrue(MyObject.self === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            
            XCTAssertFalse(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertFalse(MyObject.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        let result = MyObject.myMethod(number: 3.333, url: nil)
        XCTAssertEqual(result, 9.999)
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }
    
    // after
    func test_after_obj_sel() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod() {
                self.run = true
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        try hookClassMethodAfter(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) { object, sel in
            XCTAssertTrue(MyObject.self === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            
            XCTAssertTrue(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(MyObject.run)
            XCTAssertTrue(run)
        }
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        MyObject.myMethod()
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }
    
    // MARK: - custom closure
    
    // before
    
    func test_before_custom() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod(number: Int, url: URL) -> Int {
                self.run = true
                return number * 2
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        
        try ClassHook(MyObject.self).hookBefore(#selector(MyObject.myMethod(number:url:)), closure: { object, sel in
            XCTAssertTrue(MyObject.self === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            
            XCTAssertFalse(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertFalse(MyObject.run)
            XCTAssertTrue(run)
        } as @convention(block) (NSObject, Selector) -> Void)
        
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        let result = MyObject.myMethod(number: 77, url: URL.init(string: "https://google.com")!)
        XCTAssertEqual(result, 154)
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }
    
    // after
    
    func test_after_custom() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod(number: Int, url: URL?) -> URL? {
                self.run = true
                return URL.init(string: "https://facebook.com")
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        
        try ClassHook(MyObject.self).hookAfter(#selector(MyObject.myMethod(number:url:)), closure: { object, sel, number, url in
            XCTAssertTrue(MyObject.self === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            XCTAssertEqual(number, 77)
            XCTAssertEqual(url, URL.init(string: "https://google.com"))
            
            XCTAssertTrue(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(MyObject.run)
            XCTAssertTrue(run)
        } as @convention(block) (NSObject, Selector, Int, URL?) -> Void)
        
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        let result = MyObject.myMethod(number: 77, url: URL.init(string: "https://google.com")!)
        XCTAssertEqual(result, URL.init(string: "https://facebook.com"))
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }
    
    // instead
    
    func test_instead_custom() throws {
        class MyObject {
            static var run = false
            @objc dynamic class func myMethod(number: Int, url: URL?) -> URL? {
                self.run = true
                return URL.init(string: "https://facebook.com")
            }
        }
        
        var run = false
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        
        try ClassHook(MyObject.self).hook(#selector(MyObject.myMethod(number:url:)), closure: { original, object, sel, number, url in
            XCTAssertTrue(MyObject.self === object)
            XCTAssertEqual(sel, #selector(MyObject.myMethod))
            XCTAssertEqual(number, 77)
            XCTAssertEqual(url, URL.init(string: "https://google.com"))
            
            XCTAssertFalse(MyObject.run)
            XCTAssertFalse(run)
            let result = original(object, sel, number, url)
            XCTAssertEqual(result, URL.init(string: "https://facebook.com"))
            XCTAssertTrue(MyObject.run)
            XCTAssertFalse(run)
            run = true
            XCTAssertTrue(MyObject.run)
            XCTAssertTrue(run)
            return URL.init(string: "https://amazon.com")
        } as @convention(block) ((NSObject, Selector, Int, URL?) -> URL?, NSObject, Selector, Int, URL?) -> URL?)
        
        XCTAssertFalse(MyObject.run)
        XCTAssertFalse(run)
        let result = MyObject.myMethod(number: 77, url: URL.init(string: "https://google.com")!)
        XCTAssertEqual(result, URL.init(string: "https://amazon.com"))
        XCTAssertTrue(MyObject.run)
        XCTAssertTrue(run)
    }

}
