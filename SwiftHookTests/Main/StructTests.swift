//
//  OtherTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 11/9/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class StructTests: XCTestCase {
    
    func test_CGPoint_UIEvent() throws {
        class MyObject {
            @objc dynamic func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
                return true
            }
        }
        
        do {
            try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.point(inside:with:)), closure: {_, _, point, event in
                XCTAssertEqual(point, CGPoint.init(x: 11, y: 22))
                XCTAssertNil(event)
                } as @convention(block)(AnyObject, Selector, CGPoint, UIEvent?) -> Void)
            
            try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.point(inside:with:)), closure: {original, object, selector, point, event in
                XCTAssertEqual(point, CGPoint.init(x: 11, y: 22))
                XCTAssertNil(event)
                let result = original(object, selector, point, event)
                XCTAssertTrue(result)
                return result
                } as @convention(block)((AnyObject, Selector, CGPoint, UIEvent?) -> Bool, AnyObject, Selector, CGPoint, UIEvent?) -> Bool)
        } catch {
            XCTFail()
        }
        
        _ = MyObject.init().point(inside: CGPoint.init(x: 11, y: 22), with: nil)
    }
    
    func test_ComplexityStruct() throws {
        class MyObject {
            @objc dynamic func doublePoint(theStruct: ComplexityStruct) -> ComplexityStruct {
                var theStruct = theStruct
                theStruct.p = CGPoint.init(x: theStruct.p.x * 2, y: theStruct.p.y * 2)
                return theStruct
            }
        }
        
        var pointerForTesting: UInt8 = 0
        withUnsafeMutablePointer(to: &pointerForTesting) { (pointer) -> Void in
            do {
                try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.doublePoint(theStruct:)), closure: {_, _, s in
                    XCTAssertEqual(s.i, 11)
                    XCTAssertEqual(s.p, CGPoint.init(x: 22, y: 33))
                    XCTAssertEqual(s.frame, CGRect.init(x: 44, y: 55, width: 66, height: 77))
                    XCTAssertEqual(s.s.d, 88)
                    XCTAssertEqual(s.s.s.p, UnsafeMutableRawPointer(pointer))
                    
                    } as @convention(block)(AnyObject, Selector, ComplexityStruct) -> Void)
                
                try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.doublePoint(theStruct:)), closure: {original, object, selector, s in
                    XCTAssertEqual(s.i, 11)
                    XCTAssertEqual(s.p, CGPoint.init(x: 22, y: 33))
                    XCTAssertEqual(s.frame, CGRect.init(x: 44, y: 55, width: 66, height: 77))
                    XCTAssertEqual(s.s.d, 88)
                    XCTAssertEqual(s.s.s.p, UnsafeMutableRawPointer(pointer))
                    
                    var result = original(object, selector, s)
                    XCTAssertEqual(result.i, 11)
                    XCTAssertEqual(result.p, CGPoint.init(x: 44, y: 66))
                    XCTAssertEqual(result.frame, CGRect.init(x: 44, y: 55, width: 66, height: 77))
                    XCTAssertEqual(result.s.d, 88)
                    XCTAssertEqual(result.s.s.p, UnsafeMutableRawPointer(pointer))
                    
                    result.s.d = 99
                    return result
                    } as @convention(block)((AnyObject, Selector, ComplexityStruct) -> ComplexityStruct, AnyObject, Selector, ComplexityStruct) -> ComplexityStruct)
            } catch {
                XCTFail()
            }
            
            let s = ComplexityStruct.init(i: 11, p: CGPoint.init(x: 22, y: 33), frame: CGRect.init(x: 44, y: 55, width: 66, height: 77), s: ComplexityStruct.__Unnamed_struct_s.init(d: 88, s: ComplexityStruct.__Unnamed_struct_s.__Unnamed_struct_s.init(p: pointer, s: ComplexityStruct.__Unnamed_struct_s.__Unnamed_struct_s.__Unnamed_struct_s.init())))
            
            let result = MyObject.init().doublePoint(theStruct: s)
            
            XCTAssertEqual(result.i, 11)
            XCTAssertEqual(result.p, CGPoint.init(x: 44, y: 66))
            XCTAssertEqual(result.frame, CGRect.init(x: 44, y: 55, width: 66, height: 77))
            XCTAssertEqual(result.s.d, 99)
            XCTAssertEqual(result.s.s.p, UnsafeMutableRawPointer(pointer))
            
        }
    }
    
}
