//
//  AspectsSwiftTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 27/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
import Aspects

class AspectsSwiftTests: XCTestCase {
    
    func testModifyIntReture() {
        do {
            try self.aspect_hook(#selector(AspectsSwiftTests.getInt), with: .positionInstead, usingBlock: { aspectInfo in
                let invocation = aspectInfo.originalInvocation()!
                invocation.invoke()
                var result: Int!
                withUnsafeMutablePointer(to: &result) { (p) -> Void in
                    invocation.getReturnValue(UnsafeMutableRawPointer(p))
                }
                XCTAssertEqual(result, 999)
                result = 333
                withUnsafeMutablePointer(to: &result) { (p) -> Void in
                    invocation.setReturnValue(UnsafeMutableRawPointer(p))
                }
                } as @convention(block) (AspectInfo) -> Void)
            
            let result = self.getInt()
            XCTAssertEqual(result, 333)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // Aspects doesn't support Swift in this case.
    func testModifyObjectReture() {
        do {
            try self.aspect_hook(#selector(AspectsSwiftTests.getRequest), with: .positionInstead, usingBlock: { aspectInfo in
                let invocation = aspectInfo.originalInvocation()!
                invocation.invoke()
                
                unowned var result: NSURLRequest?
                withUnsafeMutablePointer(to: &result) { (p) -> Void in
                    invocation.getReturnValue(UnsafeMutableRawPointer(p))
                }
                XCTAssertEqual(result?.url?.absoluteString, "https://www.shopee.com")
                
                var new = NSURLRequest(url: URL(string: "https://www.google.com")!)
                withUnsafeMutablePointer(to: &new) { (p) -> Void in
                    invocation.setReturnValue(UnsafeMutableRawPointer(p))
                    invocation.retainArguments()
                }
                } as @convention(block) (AspectInfo) -> Void)
            
            let result = self.getRequest()
            XCTAssertEqual(result.url?.absoluteString, "https://www.google.com")
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
