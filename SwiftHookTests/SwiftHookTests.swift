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
    
    // MARK: - 1. Call the hook closure before executing specified instance’s method.
    func test_Specified_Instance_With_Before_Mode() {
        
        class MyObject { // The class doesn’t have to inherit from NSObject. of course inheriting from NSObject works fine.
            @objc dynamic func sayHello() { // The key words of methods `@objc` and `dynamic` are necessary.
                print("Hello!")
            }
        }
        
        do {
            let object = MyObject()
            let token = try hookBefore(object: object, selector: #selector(MyObject.sayHello)) {
                print("You will say hello, right?")
            }
            object.sayHello()
            token.cancelHook() // cancel the hook
        } catch {
            XCTFail()
        }
        
    }
    
    // MARK: - 2. Call the hook closure after executing specified instance's method. And get the parameters.
    func test_Specified_Instance_With_After_Mode_Get_Parameters() {
        
        class MyObject {
            @objc dynamic func sayHi(name: String) {
                print("Hi! \(name)")
            }
        }
        
        do {
            let object = MyObject()
            
            // 1. The first parameter mush be AnyObject or NSObject or YOUR CLASS (In this case. It has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
            // 2. The second parameter mush be Selector.
            // 3. The rest of the parameters are the same as the method.
            // 4. The return type mush be Void if you hook with `before` and `after` mode.
            // 5. The key word `@convention(block)` is necessary
            let hookClosure = { object, selector, name in
                print("Nice to see you \(name)")
                print("The object is: \(object)")
                print("The selector is: \(selector)")
            } as @convention(block) (AnyObject, Selector, String) -> Void
            let token = try hookAfter(object: object, selector: #selector(MyObject.sayHi), closure: hookClosure)
            
            object.sayHi(name: "Yanni")
            token.cancelHook()
        } catch {
            XCTFail()
        }
        
    }
    
    // MARK: - 3. Totally override the mehtod for specified instance.
    func test_Specified_Instance_With_Instead_Mode() {
        
        class MyObject {
            @objc dynamic func sum(left: Int, right: Int) -> Int {
                return left + right
            }
        }
        
        do {
            let object = MyObject()
            
            // 1. The first parameter mush be an closure. This closure means original method. The parameters of it are the same as "How to use: Case 2". The return type of it must be the same as original method's.
            // 2. The rest of the parameters are the same as "How to use: Case 2".
            // 3. The return type mush be the same as original method's.
            let hookClosure = {original, object, selector, left, right in
                let result = original(object, selector, left, right)
                // You can call original with the different parameters:
                // let result = original(object, selector, 12, 27).
                // You also can change the object and selector if you want. Don't even call the original method if needed.
                print("\(left) + \(right) equals \(result)")
                return left * right
            } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Int
            let token = try hookInstead(object: object, selector: #selector(MyObject.sum(left:right:)), closure: hookClosure)
            let left = 3
            let right = 4
            let result = object.sum(left: left, right: right)
            print("\(left) * \(right) equals \(result)")
            token.cancelHook()
        } catch {
            XCTFail()
        }
        
    }
    
    // MARK: - 4. Call the hook closure before executing the method of all instances of the class.
    func test_All_Instances_With_Before_Mode() {
        
        class MyObject {
            @objc dynamic func sayHello() {
                print("Hello!")
            }
        }
        
        do {
            let token = try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.sayHello)) {
                print("You will say hello, right?")
            }
            MyObject().sayHello()
            token.cancelHook()
        } catch {
            XCTFail()
        }
        
    }
    
    // MARK: - 5. Call the hook closure before executing the class method.
    func test_Class_With_After_Mode() {
        
        class MyObject {
            @objc dynamic class func sayHello() {
                print("Hello!")
            }
        }
        
        do {
            let token = try hookClassMethodBefore(targetClass: MyObject.self, selector: #selector(MyObject.sayHello)) {
                print("You will say hello, right?")
            }
            MyObject.sayHello()
            token.cancelHook()
        } catch {
            XCTFail()
        }
        
    }
    
    // MARK: - Hook dealloc
    
    class MyNSObject: NSObject {
        deinit {
            print("deinit executed")
        }
    }
    
    class MyPureSwiftObject {
        deinit {
            print("deinit executed")
        }
    }
    
    // Perform the hook closure before executing the instance dealloc method. This API only works for NSObject.
    func test_Specified_Instance_Dealloc_With_Before_Mode() {
        do {
            try autoreleasepool {
                let object = MyNSObject()
                _ = try hookDeallocBefore(object: object) {
                    print("released!")
                }
            }
        } catch {
            XCTFail()
        }
    }
    
    // Perform hook closure after executing the instance dealloc method. This isn't using runtime. Just add a "Tail" to the instance. The instance is the only object retaining "Tail" object. So when the instance releasing. "Tail" know this event. This API can work for NSObject and pure Swift object.
    func test_Specified_Instance_Dealloc_With_After_Tail_Mode() {
        do {
            try autoreleasepool {
                let object = MyPureSwiftObject()
                _ = try hookDeallocAfterByTail(object: object) {
                    print("released!")
                }
            }
        } catch {
            XCTFail()
        }
    }
    
    // Totally override the dealloc mehtod for specified instance. Have to call original to avoid memory leak. This API only works for NSObject.
    func test_Specified_Instance_Dealloc_With_Instead_Mode() {
        do {
            try autoreleasepool {
                let object = MyNSObject()
                _ = try hookDeallocInstead(object: object) { original in
                    print("before release!")
                    original() // have to call original "dealloc" to avoid memory leak!!!
                    print("released!")
                }
            }
        } catch {
            XCTFail()
        }
    }
    
    // Perform the hook closure before executing the dealloc method of all instances of the class. This API only works for NSObject.
    func test_All_Instances_Dealloc_With_Before_Mode() {
        do {
            let token = try hookDeallocBefore(targetClass: UIViewController.self) {
                print("released!")
            }
            autoreleasepool {
                _ = UIViewController()
            }
            token.cancelHook()
        } catch {
            XCTFail()
        }
    }
    
    // MARK: - Complicated test cases
    
    func testComplicated() {
        
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
    
}

// TODO: 测试用例。 循环hook。随机生成参数，记录结果
