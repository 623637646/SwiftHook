//
//  OrderTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 27/8/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class OrderTests: XCTestCase {
    
    func test_URLs() {
        
        class Request: NSObject {
            @objc dynamic func generateRequest(url: URL) -> NSURLRequest {
                return NSURLRequest.init(url: url)
            }
        }
        
        do {
            var deallocOrder = [Int]()
            try autoreleasepool {
                let targetClass = Request.self
                let object = Request()
                let selector = #selector(Request.generateRequest(url:))
                var order = [Int]()
                let urlGoogle = "https://www.google.com"
                let urlFacebook = "https://www.facebook.com"
                let urlApple = "https://www.apple.com"
                let urlAmazon = "https://www.amazon.com"
                let urlShopee = "https://www.shopee.com"
                
                try hookBefore(targetClass: targetClass, selector: selector, closure: {_, _, url in
                    order.append(2)
                    XCTAssertEqual(url.absoluteString, urlApple)
                    } as @convention(block) (AnyObject, Selector, URL) -> Void)
                
                try hookAfter(targetClass: targetClass, selector: selector, closure: {_, _, url in
                    order.append(5)
                    XCTAssertEqual(url.absoluteString, urlApple)
                    } as @convention(block) (AnyObject, Selector, URL) -> Void)
                
                try hookInstead(targetClass: targetClass, selector: selector, closure: {original, o, s, url in
                    order.append(3)
                    XCTAssertEqual(url.absoluteString, urlFacebook)
                    let request = original(o, s, URL.init(string: urlApple)!)
                    XCTAssertEqual(request.url?.absoluteString, urlApple)
                    let newRequest = NSURLRequest.init(url: URL.init(string: urlAmazon)!)
                    order.append(4)
                    return newRequest
                    } as @convention(block) ((AnyObject, Selector, URL) -> NSURLRequest, AnyObject, Selector, URL) -> NSURLRequest)
                
                try hookBefore(object: object, selector: selector, closure: {_, _, url in
                    order.append(0)
                    XCTAssertEqual(url.absoluteString, urlFacebook)
                    } as @convention(block) (AnyObject, Selector, URL) -> Void)
                
                try hookAfter(object: object, selector: selector, closure: {_, _, url in
                    order.append(7)
                    XCTAssertEqual(url.absoluteString, urlFacebook)
                    } as @convention(block) (AnyObject, Selector, URL) -> Void)
                
                try hookInstead(object: object, selector: selector, closure: {original, o, s, url in
                    order.append(1)
                    XCTAssertEqual(url.absoluteString, urlGoogle)
                    let request = original(o, s, URL.init(string: urlFacebook)!)
                    XCTAssertEqual(request.url?.absoluteString, urlAmazon)
                    let newRequest = NSURLRequest.init(url: URL.init(string: urlShopee)!)
                    order.append(6)
                    return newRequest
                    } as @convention(block) ((AnyObject, Selector, URL) -> NSURLRequest, AnyObject, Selector, URL) -> NSURLRequest)
                
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
                XCTAssertEqual(order, [1, 0, 3, 2, 5, 4, 7, 6])
            }
            XCTAssertEqual(deallocOrder, [1, 0, 3, 2, 4, 6, 5, 8, 7])
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Dynamic_Checking() {
        
        class Order: NSObject {
            var value = [Int]()
        }
        
        class MyObject {
            static let methodNumber = Int.random(in: Int.min ... Int.max)
            
            @objc dynamic func myMethod(order: Order) {
                order.value.append(MyObject.methodNumber)
            }
        }
        
        let createBeforeOrAfterHookClosure = { number in
            return {_, _, order in
                order.value.append(number)
            } as @convention(block) (AnyObject, Selector, Order) -> Void    // Can't remove "as @convention(block) (AnyObject, Selector, Order) -> Void" here, It may be a bug of compiler.
        } as (Int) -> @convention(block) (AnyObject, Selector, Order) -> Void
        
        let createInsteadHookClosure = { number in
            return {original, object, selector, order in
                order.value.append(-number)
                original(object, selector, order)
                order.value.append(number)
            }
        } as (Int) -> @convention(block) ((AnyObject, Selector, Order) -> Void, AnyObject, Selector, Order) -> Void
        
        do {
            let order = Order.init()
            let object = MyObject.init()
            
            var classBefore = [Int]()
            var classAfter = [Int]()
            var classInstead = [Int]()
            var objectBefore = [Int]()
            var objectAfter = [Int]()
            var objectInstead = [Int]()
            
            for _ in 0 ... 1000 {
                let hookClass = Bool.random()
                let hookMode = Int.random(in: 0 ... 2)
                let randomNumber = Int.random(in: Int.min ... Int.max)
                if hookClass {
                    // hook class
                    switch hookMode {
                    case 0:
                        classBefore.append(randomNumber)
                        try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod(order:)), closure: createBeforeOrAfterHookClosure(randomNumber))
                    case 1:
                        classInstead.append(randomNumber)
                        try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.myMethod(order:)), closure: createInsteadHookClosure(randomNumber))
                    case 2:
                        classAfter.append(randomNumber)
                        try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.myMethod(order:)), closure: createBeforeOrAfterHookClosure(randomNumber))
                    default:
                        XCTFail()
                    }
                } else {
                    // hook object
                    switch hookMode {
                    case 0:
                        objectBefore.append(randomNumber)
                        try hookBefore(object: object, selector: #selector(MyObject.myMethod(order:)), closure: createBeforeOrAfterHookClosure(randomNumber))
                    case 1:
                        objectInstead.append(randomNumber)
                        try hookInstead(object: object, selector: #selector(MyObject.myMethod(order:)), closure: createInsteadHookClosure(randomNumber))
                    case 2:
                        objectAfter.append(randomNumber)
                        try hookAfter(object: object, selector: #selector(MyObject.myMethod(order:)), closure: createBeforeOrAfterHookClosure(randomNumber))
                    default:
                        XCTFail()
                    }
                }
            }
            object.myMethod(order: order)
            
            var exceptOrder = [Int]()
            exceptOrder.append(contentsOf: objectInstead.map({-$0}).reversed())
            exceptOrder.append(contentsOf: objectBefore.reversed())
            exceptOrder.append(contentsOf: classInstead.map({-$0}).reversed())
            exceptOrder.append(contentsOf: classBefore.reversed())
            exceptOrder.append(MyObject.methodNumber)
            exceptOrder.append(contentsOf: classAfter.reversed())
            exceptOrder.append(contentsOf: classInstead.map({$0}))
            exceptOrder.append(contentsOf: objectAfter.reversed())
            exceptOrder.append(contentsOf: objectInstead.map({$0}))
            
            XCTAssertEqual(order.value, exceptOrder)
        } catch {
            XCTFail()
        }
    }
    
    func test_all_instances_method_and_specified_instance_method() throws {
        class MyObject {
            @objc dynamic func myMethod() {
                
            }
        }
        
        var order = [Int]()
        
        try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) {
            order.append(8)
        }
        
        try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) {
            order.append(7)
        }
        
        try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(6)
            original(obj, sel)
            order.append(11)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        
        try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(5)
            original(obj, sel)
            order.append(12)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        
        try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) {
            order.append(10)
        }
        
        try hookAfter(targetClass: MyObject.self, selector: #selector(MyObject.myMethod)) {
            order.append(9)
        }
        
        let object = MyObject.init()
        
        try hookBefore(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(4)
        }
        
        try hookBefore(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(3)
        }
        
        try hookInstead(object: object, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(2)
            original(obj, sel)
            order.append(15)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        
        try hookInstead(object: object, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(1)
            original(obj, sel)
            order.append(16)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)
        
        try hookAfter(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(14)
        }
        
        try hookAfter(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(13)
        }
        
        object.myMethod()
        
        XCTAssertEqual(order, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    }
    
    func test_all_instances_method_and_specified_instance_method_dynamic_class() throws {
        class MyObject {
            @objc dynamic func myMethod() {

            }
        }

        var order = [Int]()

        let object = MyObject.init()

        try hookBefore(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(6)
        }

        try hookBefore(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(5)
        }

        try hookInstead(object: object, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(2)
            original(obj, sel)
            order.append(15)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)

        try hookInstead(object: object, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(1)
            original(obj, sel)
            order.append(16)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)

        try hookAfter(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(10)
        }

        try hookAfter(object: object, selector: #selector(MyObject.myMethod)) {
            order.append(9)
        }
        
        let theClass: AnyClass = object_getClass(object)!
        
        try hookBefore(targetClass: theClass, selector: #selector(MyObject.myMethod)) {
            order.append(8)
        }

        try hookBefore(targetClass: theClass, selector: #selector(MyObject.myMethod)) {
            order.append(7)
        }

        try hookInstead(targetClass: theClass, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(4)
            original(obj, sel)
            order.append(13)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)

        try hookInstead(targetClass: theClass, selector: #selector(MyObject.myMethod), closure: {original, obj, sel in
            order.append(3)
            original(obj, sel)
            order.append(14)
        } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void)

        try hookAfter(targetClass: theClass, selector: #selector(MyObject.myMethod)) {
            order.append(12)
        }

        try hookAfter(targetClass: theClass, selector: #selector(MyObject.myMethod)) {
            order.append(11)
        }

        object.myMethod()

        XCTAssertEqual(order, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    }
    
}
