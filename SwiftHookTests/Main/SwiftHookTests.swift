//
//  SwiftHookTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class SwiftHookTests: XCTestCase {
    
    // MARK: Basic usage
    
    func testSingleHookBefore() {
        let testObject = TestObject()
        let token = try? hookBefore(object: testObject, selector: #selector(TestObject.noArgsNoReturnFunc)) {
            // run your code
            print("hooked!")
        }
        testObject.noArgsNoReturnFunc()
        token?.cancelHook() // cancel the hook
    }
    
    func testSingleHookAfterWithArguments() {
        let testObject = TestObject()
        let token = try? hookAfter(object: testObject, selector: #selector(TestObject.sumFunc(a:b:)), closure: { a, b in
            // get the arguments of the function
            print("arg1 is \(a)") // arg1 is 3
            print("arg2 is \(b)") // arg2 is 4
            } as @convention(block) (Int, Int) -> Void)
        _ = testObject.sumFunc(a: 3, b: 4)
        token?.cancelHook() // cancel the hook
    }
    
    func testSingleHookInstead() {
        let testObject = TestObject()
        let token = try? hookInstead(object: testObject, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
            // get the arguments of the function
            print("arg1 is \(a)") // arg1 is 3
            print("arg2 is \(b)") // arg2 is 4
            
            // run original function
            let result = original(a, b)
            print("original result is \(result)") // result = 7
            return 9
            } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int)
        let result = testObject.sumFunc(a: 3, b: 4) // result
        print("hooked result is \(result)") // result = 9
        token?.cancelHook() // cancel the hook
    }
    
    func testAllInstances() {
        let token = try? hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc)) {
            // run your code
            print("hooked!")
        }
        TestObject().noArgsNoReturnFunc()
        token?.cancelHook() // cancel the hook
    }
    
    func testClassMethod() {
        let token = try? hookClassMethodBefore(targetClass: TestObject.self, selector: #selector(TestObject.classMethodNoArgsNoReturnFunc)) {
            // run your code
            print("hooked!")
        }
        TestObject.classMethodNoArgsNoReturnFunc()
        token?.cancelHook() // cancel the hook
    }
    
    // MARK: Advanced usage
    
    func testSingleHookBeforeDeallocForNSObject() {
        autoreleasepool {
            let object = NSObject()
            _ = try? hookDeallocBefore(object: object) {
                print("released!")
            }
        }
    }
    
    func testSingleHookAfterDeallocForAnyObject() {
        autoreleasepool {
            let object = TestObject()
            _ = try? hookDeallocAfterByTail(object: object) {
                print("released!")
            }
        }
    }
    
    func testSingleHookInsteadDeallocForNSObject() {
        autoreleasepool {
            let object = NSObject()
            _ = try? hookDeallocInstead(object: object) { original in
                print("before release!")
                original() // have to call original "dealloc" to avoid memory leak!!!
                print("released!")
            }
        }
    }
    
    func testAllInstancesHookBeforeDeallocForNSObject() {
        _ = try? hookDeallocBefore(targetClass: UIViewController.self) {
            print("released!")
        }
        autoreleasepool {
            _ = UIViewController()
        }
    }
    
    // MARK: Complicated test cases
    
    class Request: NSObject {
        @objc dynamic func generateRequest(url: URL) -> NSURLRequest {
            return NSURLRequest.init(url: url)
        }
    }
    
    func testComplicated() {
        do {
            var deallocOrder = [Int]()
            try autoreleasepool {
                let targetClass = Request.self
                let object = Request()
                let selector = #selector(Request.generateRequest(url:))
                var order = [Int]()
                let urlGoogle = "https://www.shopee.com"
                let urlFacebook = "https://www.facebook.com"
                let urlApple = "https://www.apple.com"
                let urlAmazon = "https://www.amazon.com"
                let urlShopee = "https://www.shopee.com"
                
                try hookBefore(targetClass: targetClass, selector: selector, closure: { url in
                    order.append(2)
                    XCTAssertEqual(url.absoluteString, urlFacebook)
                    } as @convention(block) (URL) -> Void)
                
                try hookAfter(targetClass: targetClass, selector: selector, closure: { url in
                    order.append(5)
                    XCTAssertEqual(url.absoluteString, urlFacebook)
                    } as @convention(block) (URL) -> Void)
                
                try hookInstead(targetClass: targetClass, selector: selector, closure: {original, url in
                    order.append(3)
                    XCTAssertEqual(url.absoluteString, urlFacebook)
                    let request = original(URL.init(string: urlApple)!)
                    XCTAssertEqual(request.url?.absoluteString, urlApple)
                    let newRequest = NSURLRequest.init(url: URL.init(string: urlAmazon)!)
                    order.append(4)
                    return newRequest
                    } as @convention(block) ((URL) -> NSURLRequest, URL) -> NSURLRequest)
                
                try hookBefore(object: object, selector: selector, closure: { url in
                    order.append(0)
                    XCTAssertEqual(url.absoluteString, urlGoogle)
                    } as @convention(block) (URL) -> Void)
                
                try hookAfter(object: object, selector: selector, closure: { url in
                    order.append(7)
                    XCTAssertEqual(url.absoluteString, urlGoogle)
                    } as @convention(block) (URL) -> Void)
                
                try hookInstead(object: object, selector: selector, closure: {original, url in
                    order.append(1)
                    XCTAssertEqual(url.absoluteString, urlGoogle)
                    let request = original(URL.init(string: urlFacebook)!)
                    XCTAssertEqual(request.url?.absoluteString, urlAmazon)
                    let newRequest = NSURLRequest.init(url: URL.init(string: urlShopee)!)
                    order.append(6)
                    return newRequest
                    } as @convention(block) ((URL) -> NSURLRequest, URL) -> NSURLRequest)
                
                try hookDeallocBefore(targetClass: Request.self, closure: {
                    deallocOrder.append(2)
                })
                
                try hookDeallocAfter(targetClass: Request.self, closure: {
                    deallocOrder.append(6)
                })
                
                try hookDeallocInstead(targetClass: Request.self, closure: { (original) in
                    deallocOrder.append(3)
                    original()
                    deallocOrder.append(5)
                })
                
                try hookDeallocBefore(object: object, closure: {
                    deallocOrder.append(0)
                })
                
                try hookDeallocAfter(object: object, closure: {
                    deallocOrder.append(8)
                })
                
                try hookDeallocAfterByTail(object: object, closure: {
                    deallocOrder.append(4)
                })
                
                try hookDeallocInstead(object: object) { (original) in
                    deallocOrder.append(1)
                    original()
                    deallocOrder.append(7)
                }
                
                let request = object.generateRequest(url: URL.init(string: urlGoogle)!)
                XCTAssertEqual(request.url?.absoluteString, urlShopee)
                XCTAssertEqual(order, [0, 1, 2, 3, 4, 5, 6, 7])
            }
            XCTAssertEqual(deallocOrder, [0, 1, 2, 3, 4, 5, 6, 7, 8])
        } catch {
            XCTAssertNil(error)
        }
    }
    
}
