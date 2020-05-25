//
//  SwiftHookTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

// TODO: some complicated test cases
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
            print("arg1 is \(b)") // arg1 is 4
        } as @convention(block) (Int, Int) -> Void)
        _ = testObject.sumFunc(a: 3, b: 4)
        token?.cancelHook() // cancel the hook
    }
    
    func testSingleHookInstead() {
        let testObject = TestObject()
        let token = try? hookInstead(object: testObject, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
            // get the arguments of the function
            print("arg1 is \(a)") // arg1 is 3
            print("arg1 is \(b)") // arg1 is 4
            
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
    
}

// TODO: performance tests measureBlock
