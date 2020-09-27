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
    
    func test_CGPoint_UIEvent() {
        class MyObject {
            @objc dynamic func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
                return true
            }
        }
        
        do {
            let token1 = try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.point(inside:with:)), closure: {_, _, point, event in
                XCTAssertEqual(point, CGPoint.init(x: 11, y: 22))
                XCTAssertNil(event)
                } as @convention(block)(AnyObject, Selector, CGPoint, UIEvent?) -> Void)
            
            let token2 = try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.point(inside:with:)), closure: {original, object, selector, point, event in
                XCTAssertEqual(point, CGPoint.init(x: 11, y: 22))
                XCTAssertNil(event)
                let result = original(object, selector, point, event)
                XCTAssertTrue(result)
                return result
                } as @convention(block)((AnyObject, Selector, CGPoint, UIEvent?) -> Bool, AnyObject, Selector, CGPoint, UIEvent?) -> Bool)
            _ = MyObject.init().point(inside: CGPoint.init(x: 11, y: 22), with: nil)
            token1.cancelHook()
            token2.cancelHook()
        } catch {
            XCTFail()
        }
    }
    
    func test_ComplexityStruct() {
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
                let token1 = try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.doublePoint(theStruct:)), closure: {_, _, s in
                    XCTAssertEqual(s.i, 11)
                    XCTAssertEqual(s.p, CGPoint.init(x: 22, y: 33))
                    XCTAssertEqual(s.frame, CGRect.init(x: 44, y: 55, width: 66, height: 77))
                    XCTAssertEqual(s.s.d, 88)
                    XCTAssertEqual(s.s.s.p, UnsafeMutableRawPointer(pointer))
                    
                    } as @convention(block)(AnyObject, Selector, ComplexityStruct) -> Void)
                
                let token2 = try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.doublePoint(theStruct:)), closure: {original, object, selector, s in
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
                let s = ComplexityStruct.init(i: 11, p: CGPoint.init(x: 22, y: 33), frame: CGRect.init(x: 44, y: 55, width: 66, height: 77), s: ComplexityStruct.__Unnamed_struct_s.init(d: 88, s: ComplexityStruct.__Unnamed_struct_s.__Unnamed_struct_s.init(p: pointer, s: ComplexityStruct.__Unnamed_struct_s.__Unnamed_struct_s.__Unnamed_struct_s.init())))
                
                let result = MyObject.init().doublePoint(theStruct: s)
                
                XCTAssertEqual(result.i, 11)
                XCTAssertEqual(result.p, CGPoint.init(x: 44, y: 66))
                XCTAssertEqual(result.frame, CGRect.init(x: 44, y: 55, width: 66, height: 77))
                XCTAssertEqual(result.s.d, 99)
                XCTAssertEqual(result.s.s.p, UnsafeMutableRawPointer(pointer))
                token1.cancelHook()
                token2.cancelHook()
            } catch {
                XCTFail()
            }
        }
    }
    
    func test_BigStruct() {
        class MyObject {
            @objc dynamic func doublePoint(theStruct: BigStruct) -> BigStruct {
                var theStruct = theStruct
                theStruct.frame1 = CGRect.init(x: theStruct.frame1.origin.x * 2,
                                               y: theStruct.frame1.origin.y * 2,
                                               width: theStruct.frame1.size.width * 2,
                                               height: theStruct.frame1.size.height * 2)
                return theStruct
            }
        }
        
        do {
            let token1 = try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.doublePoint(theStruct:)), closure: {_, _, s in
                XCTAssertEqual(s.frame1, CGRect.init(x: 1, y: 2, width: 3, height: 4))
                } as @convention(block)(AnyObject, Selector, BigStruct) -> Void)
            
            let token2 = try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.doublePoint(theStruct:)), closure: {original, object, selector, s in
                XCTAssertEqual(s.frame1, CGRect.init(x: 1, y: 2, width: 3, height: 4))
                var result = original(object, selector, s)
                XCTAssertEqual(result.frame1, CGRect.init(x: 2, y: 4, width: 6, height: 8))
                result.frame1 = CGRect.init(x: result.frame1.origin.x * 2,
                                            y: result.frame1.origin.y * 2,
                                            width: result.frame1.size.width * 2,
                                            height: result.frame1.size.height * 2)
                return result
                } as @convention(block)((AnyObject, Selector, BigStruct) -> BigStruct, AnyObject, Selector, BigStruct) -> BigStruct)
            let s = BigStruct.init(frame1: CGRect.init(x: 1, y: 2, width: 3, height: 4),
                                   frame2: CGRect.zero,
                                   frame3: CGRect.zero,
                                   frame4: CGRect.zero,
                                   frame5: CGRect.zero,
                                   frame6: CGRect.zero,
                                   frame7: CGRect.zero,
                                   frame8: CGRect.zero,
                                   frame9: CGRect.zero,
                                   frame10: CGRect.zero,
                                   frame11: CGRect.zero,
                                   frame12: CGRect.zero)
            
            let result = MyObject.init().doublePoint(theStruct: s)
            XCTAssertEqual(result.frame1, CGRect.init(x: 4, y: 8, width: 12, height: 16))
            token1.cancelHook()
            token2.cancelHook()
        } catch {
            XCTFail()
        }
    }
    
}
