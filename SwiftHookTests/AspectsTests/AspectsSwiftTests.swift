//
//  AspectsSwiftTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 27/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
import Aspects
import SwiftHook

class AspectsSwiftTests: XCTestCase {
    
    // MARK: Normal
    
    func testModifyIntReture() {
        do {
            try self.aspect_hook(#selector(AspectsSwiftTests.getInt), with: .positionInstead, usingBlock: { aspectInfo in
                let invocation = aspectInfo.originalInvocation()!
                invocation.invoke()
                var result: Int!
                withUnsafeMutablePointer(to: &result) { pointer in
                    invocation.getReturnValue(UnsafeMutableRawPointer(pointer))
                }
                XCTAssertEqual(result, 999)
                result = 333
                withUnsafeMutablePointer(to: &result) { pointer in
                    invocation.setReturnValue(UnsafeMutableRawPointer(pointer))
                }
                } as @convention(block) (AspectInfo) -> Void)
            
            let result = self.getInt()
            XCTAssertEqual(result, 333)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: Bugs
    
    /**
     Aspects doesn't support Swift in this case.
     */
    func testModifyObjectReture() {
        do {
            try self.aspect_hook(#selector(AspectsSwiftTests.getRequest), with: .positionInstead, usingBlock: { aspectInfo in
                let invocation = aspectInfo.originalInvocation()!
                invocation.invoke()
                
                unowned var result: NSURLRequest?
                withUnsafeMutablePointer(to: &result) { pointer in
                    invocation.getReturnValue(UnsafeMutableRawPointer(pointer))
                }
                XCTAssertEqual(result?.url?.absoluteString, "https://www.shopee.com")
                
                var new = NSURLRequest(url: URL(string: "https://www.google.com")!)
                withUnsafeMutablePointer(to: &new) { pointer in
                    invocation.setReturnValue(UnsafeMutableRawPointer(pointer))
                    invocation.retainArguments()
                }
                } as @convention(block) (AspectInfo) -> Void)
            
            let result = self.getRequest()
            XCTAssertEqual(result.url?.absoluteString, "https://www.google.com")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    /**
     Aspects's bug.
     
     # Normal case (Without "let token0 = try ObjectiveCTestObject.aspect_hook")
     
     1. Hook with SwiftHook. The object's class changed to "SwiftHook_ObjectiveCTestObject". The method's IMP changed from original to SwiftHook's IMP.
     2. Then execute "let tokenAspects = try object.aspect_hook(". The class "SwiftHook_ObjectiveCTestObject" created a new method "aspects__setNumber:" and this method call the SwiftHook's IMP.
     3. The logic is Aspects(setNumber:) -> Aspects(aspects__setNumber:) -> SwiftHook -> Original
     
     So for this case. It's fine.
     
     # Wrong Case (executing "let token0 = try ObjectiveCTestObject.aspect_hook")
     
     1. Execute "let token0 = try ObjectiveCTestObject.aspect_hook", The object's class "ObjectiveCTestObject" created a new method "aspects__setNumber:" and this method call the original IMP.
     2. Then hook with SwiftHook. The object's class changed to "SwiftHook_ObjectiveCTestObject". The method's IMP changed from original to SwiftHook's IMP.
     3. Then execute "let tokenAspects = try object.aspect_hook(". The class "SwiftHook_ObjectiveCTestObject" swizzle  "aspects__setNumber:" and "setNumber:" without adding new method in "SwiftHook_ObjectiveCTestObject" (See Aspects.m:274)
     3. The logic is Aspects(setNumber:) -> Aspects(aspects__setNumber:) -> Original
     
     So this case. Aspects skip SwiftHook
     
     */
    func testBeforeAspectsReverseCancel() {
        do {
            // --------- This test case is wrong with this code. If we comment this code. The test case works fine.
            let token0 = try ObjectiveCTestObject.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
                aspect.originalInvocation()?.invoke()
                } as @convention(block) (AspectInfo) -> Void)
            token0.remove()
            // ---------
            
            let object = ObjectiveCTestObject()
            var expectation = [Int]()
            
            let token = try ObjectHook(object).hook(#selector(setter: ObjectiveCTestObject.number), closure: { original, o, s, number in
                expectation.append(1)
                original(o, s, number)
                expectation.append(2)
                } as @convention(block) ((AnyObject, Selector, Int) -> Void, AnyObject, Selector, Int) -> Void)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            let tokenAspects = try object.aspect_hook(#selector(setter: ObjectiveCTestObject.number), with: .positionInstead, usingBlock: { aspect in
                expectation.append(3)
                aspect.originalInvocation()?.invoke()
                expectation.append(4)
                } as @convention(block) (AspectInfo) -> Void)
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            XCTAssertEqual(expectation, [])
            
            object.number = 9
            XCTAssertEqual(expectation, [3, 1, 2, 4])
            XCTAssertEqual(object.number, 9)
            
            expectation = []
            token.cancelHook()
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            object.number = 11
            XCTAssertEqual(expectation, [3, 4])
            XCTAssertEqual(object.number, 11)
            
            expectation = []
            XCTAssertTrue(tokenAspects.remove())
            XCTAssertTrue(try testGetObjectType(object: object) == .dynamic)
            object.number = 10
            XCTAssertEqual(expectation, [])
            XCTAssertEqual(object.number, 10)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: utilities
    
    @objc dynamic func getRequest() -> NSURLRequest {
        return NSURLRequest(url: URL(string: "https://www.shopee.com")!)
    }
    
    @objc dynamic func getInt() -> Int {
        return 999
    }
    
}
