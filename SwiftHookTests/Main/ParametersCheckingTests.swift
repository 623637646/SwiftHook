//
//  ParametersCheckingTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

private let retainSelector = NSSelectorFromString("retain")
private let releaseSelector = NSSelectorFromString("release")
private let autoreleaseSelector = NSSelectorFromString("autorelease")
private let blacklistSelectors = [retainSelector, releaseSelector, autoreleaseSelector]

class ParametersCheckingTests: XCTestCase {
    
    func testCanNotHookClassWithObjectAPI() {
        do {
            try hookBefore(object: randomTestClass(), selector: randomSelector(), closure: {
            })
            XCTFail()
        } catch SwiftHookError.hookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: randomTestClass(), selector: randomSelector(), closure: {
            })
            XCTFail()
        } catch SwiftHookError.hookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: randomTestClass(), selector: randomSelector(), closure: {
            })
            XCTFail()
        } catch SwiftHookError.hookClassWithObjectAPI {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testUnsupportHookPureSwiftObjectDealloc() {
        do {
            try hookBefore(object: TestObject(), selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.pureSwiftObjectDealloc {
            
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: TestObject(), selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.pureSwiftObjectDealloc {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: TestObject(), selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.pureSwiftObjectDealloc {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookBefore(targetClass: TestObject.self, selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.pureSwiftObjectDealloc {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(targetClass: TestObject.self, selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.pureSwiftObjectDealloc {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: deallocSelector, closure: {
            })
            XCTFail()
        } catch SwiftHookError.pureSwiftObjectDealloc {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testNoRespondSelector() {
        do {
            try hookBefore(targetClass: randomTestClass(), selector: #selector(NSArray.object(at:)), closure: {})
            XCTFail()
        } catch SwiftHookError.noRespondSelector {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookClassMethodAfter(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc), closure: {})
            XCTFail()
        } catch SwiftHookError.noRespondSelector {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: TestObject(), selector: #selector(TestObject.classMethodNoArgsNoReturnFunc), closure: {})
            XCTFail()
        } catch SwiftHookError.noRespondSelector {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testMissingSignature() {
        do {
            try hookBefore(targetClass: randomTestClass(), selector: #selector(TestObject.noArgsNoReturnFunc), closure: NSObject())
            XCTFail()
        } catch SwiftHookError.wrongTypeForHookClosure {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookClassMethodAfter(targetClass: TestObject.self, selector: #selector(TestObject.classMethodNoArgsNoReturnFunc), closure: 1)
            XCTFail()
        } catch SwiftHookError.wrongTypeForHookClosure {
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(object: TestObject(), selector: #selector(TestObject.noArgsNoReturnFunc), closure: {} as AnyObject)
            XCTFail()
        } catch SwiftHookError.wrongTypeForHookClosure {
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testIncompatibleClosureSignature() {
        do {
            try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { _, _ in
                return 1
            } as @convention(block) (Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The return type of the hook closure mush be `v`. But it's `q`. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: TestObject(), selector: #selector(TestObject.sumFunc(a:b:)), closure: { _, _ in
            } as @convention(block) (Int, Double) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be the same as method's. The closure parameters type is `qd`. But the method parameters type is `@:qq`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookAfter(object: TestObject(), selector: #selector(TestObject.testStructSignature(point:rect:)), closure: ({_, _ in
            } as @convention(block) (CGPoint, Double) -> Void) as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `befor` and `after` mode. The parameters type of the hook closure must be the same as method's. The closure parameters type is `{CGPoint=dd}d`. But the method parameters type is `@:{CGPoint=dd}{CGRect={CGPoint=dd}{CGSize=dd}}`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { _, _ in
            } as @convention(block) (Int, Int) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The number of hook closure parameters should be equal to the number of method parameters + 1 (The first parameter is the `original` closure. The rest is the same as method's). The hook closure parameters number is 2. The method parameters number is 4.")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testBlacklist() {
        for selector in blacklistSelectors {
            do {
                let object = ObjectiveCTestObject()
                try hookBefore(object: object, selector: selector) {
                }
                XCTFail()
            } catch SwiftHookError.blacklist {
            } catch {
                XCTAssertNil(error)
            }
            
            do {
                try hookBefore(targetClass: ObjectiveCTestObject.self, selector: selector) {
                }
                XCTFail()
            } catch SwiftHookError.blacklist {
            } catch {
                XCTAssertNil(error)
            }
        }
    }
    
    func test_Hook_Instead_Original_Closure() {
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
                let result = original(a, b)
                return Int(result)
            } as @convention(block) ((Int, Int) -> Double, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The number of hook closure parameters should be equal to the number of method parameters + 1 (The first parameter is the `original` closure. The rest is the same as method's). The hook closure parameters number is 3. The method parameters number is 4.")
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, _, b in
                let result = original(NSObject.init(), b)
                return Int(result)
            } as @convention(block) ((NSObject, Int) -> Int, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The number of hook closure parameters should be equal to the number of method parameters + 1 (The first parameter is the `original` closure. The rest is the same as method's). The hook closure parameters number is 3. The method parameters number is 4.")
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
                let result = original(a, b, 100)
                return Int(result)
            } as @convention(block) ((Int, Int, Int) -> Int, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The number of hook closure parameters should be equal to the number of method parameters + 1 (The first parameter is the `original` closure. The rest is the same as method's). The hook closure parameters number is 3. The method parameters number is 4.")
        } catch {
            XCTAssertNil(error)
        }
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, _ in
                let result = original(a)
                return Int(result)
            } as @convention(block) ((Int) -> Int, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The number of hook closure parameters should be equal to the number of method parameters + 1 (The first parameter is the `original` closure. The rest is the same as method's). The hook closure parameters number is 3. The method parameters number is 4.")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, o, s, a, b in
                let result = original(o, s, a, b)
                return Int(result)
            } as @convention(block) ((AnyObject, Selector, Int, Int) -> Double, AnyObject, Selector, Int, Int) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The return type of the original closure (the hook closure's first parameter) should be the same as method's return type. But the return type of the original closure is `d`, The return type of the method is `q`. Thay are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, o, s, a, b in
                let result = original(o, s, a, b)
                return Double(result)
            } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Int) -> Double as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The return type of the hook closure should be the same as method's return type. But the return type of the hook closure is `d`, The return type of the method is `q`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: TestObject.self, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, o, s, a, b in
                let result = original(o, s, a, Int(b))
                return Int(result)
            } as @convention(block) ((AnyObject, Selector, Int, Int) -> Int, AnyObject, Selector, Int, Double) -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The parameters type of the hook closure without firt one (The first parameter is the `original` closure) must be the same as the method's. But now the parameters type of the hook closure without firt one is `@:qd`. But the method parameters type is `@:qq`. They are not the same. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Hook_Dealloc() {
        do {
            try hookBefore(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: {
                return 1
            } as @convention(block) () -> Int as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `befor` and `after` mode. The return type of the hook closure mush be `v`. But it's `q`. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookBefore(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { _ in
                
            } as @convention(block) (String) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `befor` and `after` mode. The parameters of the hook closure mush be empty. But it's `@`. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original, o, s in
                original(o, s)
            } as @convention(block) ((AnyObject, Selector) -> Void, AnyObject, Selector) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `instead` mode. The number of hook closure parameters should be 1 (The parameter is the `original` closure). But now it's 3.")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { _ in
                
            } as @convention(block) (AnyObject) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "For `instead` mode. The type of the hook closure's first parameter should be a closure (It's `original` closure). But the signature is `@`. By right it should be \"@?\". For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original in
                _ = original()
            } as @convention(block) (() -> CGPoint) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `instead` mode. The return type of the original closure (the hook closure's first parameter) should be `v`. But the return type of the original closure is `{CGPoint=dd}`. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original in
                original(1, 1.1)
            } as @convention(block) ((Int, Double) -> Void) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `instead` mode. The parameters of the original closure (the hook closure's first parameter) must be empty. The original closure parameters type is `qd`. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original in
                original()
                return "lol"
            } as @convention(block) (() -> Void) -> String as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `instead` mode. The return type of the hook closure should be `v`. But the return type of the hook closure is `@`. For more about Type Encodings: https://nshipster.com/type-encodings/")
        } catch {
            XCTAssertNil(error)
        }
        
        do {
            try hookInstead(targetClass: ObjectiveCTestObject.self, selector: deallocSelector, closure: { original, _ in
                original()
            } as @convention(block) (() -> Void, URL) -> Void as AnyObject)
            XCTFail()
        } catch SwiftHookError.incompatibleClosureSignature(description: let description) {
            XCTAssertEqual(description, "Hook \"dealloc\" method for `instead` mode. The number of hook closure parameters should be 1 (The parameter is the `original` closure). But now it's 2.")
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_Empty_Struct() {
        class MyObject {
            @objc dynamic func myMethod1() -> EmptyStruct {
                return EmptyStruct.init()
            }
            
            @objc dynamic func myMethod2(s: EmptyStruct) {
                
            }
            
            @objc dynamic func myMethod3(s: EmptyStruct) -> EmptyStruct {
                return EmptyStruct.init()
            }
            
            @objc dynamic func myMethod4() -> InternalEmptyStruct {
                return InternalEmptyStruct.init()
            }
            
            @objc dynamic func myMethod5(s: InternalEmptyStruct) {
                
            }
            
            @objc dynamic func myMethod6(s: InternalEmptyStruct) -> InternalEmptyStruct {
                return InternalEmptyStruct.init()
            }
        }
        
        do {
            try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.myMethod1), closure: { _, _, _ in
                return EmptyStruct.init()
            } as @convention(block) ((NSObject, Selector) -> EmptyStruct, NSObject, Selector) -> EmptyStruct)
            XCTFail()
        } catch SwiftHookError.emptyStruct {
        } catch {
            XCTFail()
        }
        
        do {
            try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod2), closure: {
                
            })
            XCTFail()
        } catch SwiftHookError.emptyStruct {
        } catch {
            XCTFail()
        }
        
        do {
            try hookAfter(object: MyObject(), selector: #selector(MyObject.myMethod3), closure: {
                
            })
            XCTFail()
        } catch SwiftHookError.emptyStruct {
        } catch {
            XCTFail()
        }
        
        do {
            try hookInstead(targetClass: MyObject.self, selector: #selector(MyObject.myMethod4), closure: { _, _, _ in
                return InternalEmptyStruct.init()
            } as @convention(block) ((NSObject, Selector) -> InternalEmptyStruct, NSObject, Selector) -> InternalEmptyStruct)
            XCTFail()
        } catch SwiftHookError.emptyStruct {
        } catch {
            XCTFail()
        }
        
        do {
            try hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.myMethod5), closure: {
                
            })
            XCTFail()
        } catch SwiftHookError.emptyStruct {
        } catch {
            XCTFail()
        }
        
        do {
            try hookAfter(object: MyObject(), selector: #selector(MyObject.myMethod6), closure: {
                
            })
            XCTFail()
        } catch SwiftHookError.emptyStruct {
        } catch {
            XCTFail()
        }
        
    }
    
    func test_KVOed() throws {
        do {
            class MyObject: NSObject {
                @objc dynamic var number: Int = 0
            }
            let obj = MyObject.init()
            var runned = false
            let token = obj.observe(\.number) { (_, _) in
                runned = true
            }
            obj.number = 1
            XCTAssertTrue(runned)
            try obj.sh_hookDeallocAfter {
                
            }
            _ = token
        } catch let error as NSError where error.code == 3 && error.userInfo[NSLocalizedDescriptionKey] as? String == "Unsupport to hook KVO'ed Object" {
        }
    }
}
