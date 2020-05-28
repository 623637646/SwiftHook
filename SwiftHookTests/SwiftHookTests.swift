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
    
    class MyObject {
        @objc dynamic func noArgsNoReturnFunc() {
        }
        @objc dynamic func sumFunc(a: Int, b: Int) -> Int {
            return a + b
        }
        @objc dynamic class func classMethodNoArgsNoReturnFunc() {
        }
    }
    
    // MARK: Basic usage
    
    // Perform the hook closure before executing specified instance's method.
    func testSingleHookBefore() {
        let object = MyObject()
        let token = try? hookBefore(object: object, selector: #selector(MyObject.noArgsNoReturnFunc)) {
            // run your code
            print("hooked!")
        }
        object.noArgsNoReturnFunc()
        token?.cancelHook() // cancel the hook
    }
    
    // Perform the hook closure after executing specified instance's method. And get the parameters.
    func testSingleHookAfterWithArguments() {
        let object = MyObject()
        let token = try? hookAfter(object: object, selector: #selector(MyObject.sumFunc(a:b:)), closure: { a, b in
            // get the arguments of the function
            print("arg1 is \(a)") // arg1 is 3
            print("arg2 is \(b)") // arg2 is 4
            } as @convention(block) (Int, Int) -> Void)
        _ = object.sumFunc(a: 3, b: 4)
        token?.cancelHook() // cancel the hook
    }
    
    // Totally override the mehtod for specified instance. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
    func testSingleHookInstead() {
        let object = MyObject()
        let token = try? hookInstead(object: object, selector: #selector(MyObject.sumFunc(a:b:)), closure: { original, a, b in
            // get the arguments of the function
            print("arg1 is \(a)") // arg1 is 3
            print("arg2 is \(b)") // arg2 is 4
            
            // run original function
            let result = original(a, b) // Or change the parameters: let result = original(-1, -2)
            print("original result is \(result)") // result = 7
            return 9
            } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int)
        let result = object.sumFunc(a: 3, b: 4) // result
        print("hooked result is \(result)") // result = 9
        token?.cancelHook() // cancel the hook
    }
    
    // Perform the hook closure before executing the method of all instances of the class.
    func testAllInstances() {
        let token = try? hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.noArgsNoReturnFunc)) {
            // run your code
            print("hooked!")
        }
        MyObject().noArgsNoReturnFunc()
        token?.cancelHook() // cancel the hook
    }
    
    // Perform the hook closure before executing the class method.
    func testClassMethod() {
        let token = try? hookClassMethodBefore(targetClass: MyObject.self, selector: #selector(MyObject.classMethodNoArgsNoReturnFunc)) {
            // run your code
            print("hooked!")
        }
        MyObject.classMethodNoArgsNoReturnFunc()
        token?.cancelHook() // cancel the hook
    }
    
    // MARK: Advanced usage
    
    class MyNSObject: NSObject {
        deinit {
            print("deinit executed")
        }
    }
    
    // Perform the hook closure before executing the instance dealloc method. This API only works for NSObject.
    func testSingleHookBeforeDeallocForNSObject() {
        autoreleasepool {
            let object = MyNSObject()
            _ = try? hookDeallocBefore(object: object) {
                print("released!")
            }
        }
    }
    
    // Perform hook closure after executing the instance dealloc method. This isn't using runtime. Just add a "Tail" to the instance. The instance is the only object retaining "Tail" object. So when the instance releasing. "Tail" know this event. This API can work for NSObject and pure Swift object.
    func testSingleHookAfterDeallocForAnyObject() {
        autoreleasepool {
            let object = MyObject()
            _ = try? hookDeallocAfterByTail(object: object) {
                print("released!")
            }
        }
    }
    
    // Totally override the dealloc mehtod for specified instance. Have to call original to avoid memory leak. This API only works for NSObject.
    func testSingleHookInsteadDeallocForNSObject() {
        autoreleasepool {
            let object = MyNSObject()
            _ = try? hookDeallocInstead(object: object) { original in
                print("before release!")
                original() // have to call original "dealloc" to avoid memory leak!!!
                print("released!")
            }
        }
    }
    
    // Perform the hook closure before executing the dealloc method of all instances of the class. This API only works for NSObject.
    func testAllInstancesHookBeforeDeallocForNSObject() {
        _ = try? hookDeallocBefore(targetClass: UIViewController.self) {
            print("released!")
        }
        autoreleasepool {
            _ = UIViewController()
        }
    }
    
    func testRetainAndRelease() {
        let tokenRetain = try? hookBefore(targetClass: MyNSObject.self, selector: NSSelectorFromString("retain")) {
            print("retain!")
        }
        
        let tokenRelease = try? hookAfter(targetClass: MyNSObject.self, selector: NSSelectorFromString("release")) {
            print("release!")
        }
        autoreleasepool {
            let object = MyNSObject()
            let object2 = object
            _ = object2
        }
        tokenRetain?.cancelHook()
        tokenRelease?.cancelHook()
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
