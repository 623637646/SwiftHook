//
//  HookContextTests.swift
//  SwiftHookTests
//
//  Created by Yanni Wang on 6/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import XCTest
@testable import SwiftHook

class HookContextTests: XCTestCase {
    
    let InternalErrorLineSignature = 115
    let InternalErrorLineMethod = 107
    
    // MARK: invalid closure
    
    func testInvalidClosureWithSwiftClosure() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = {} as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSignature)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInvalidClosureWithSwiftObject() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = PureSwift()
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSignature)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testInvalidClosureWithObjectiveCObject() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.noArgsNoReturnFunc)
        let mode: HookMode = .before
        let closure = NSObject()
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineSignature)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: invalid class & selector
    
    func testPureSwift() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = PureSwift.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    func testHookNoRespondSelector() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(getter: UIView.alpha)
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: No method from self.
    
    func testNoMethodFromSelf() {
        let contextCount = HookContext.debugToolsGetAllHookContext().count
        let targetClass = TestObject.self
        let selector = #selector(TestObject.superFunc(arg:))
        let mode: HookMode = .before
        let closure = ({} as @convention(block) () -> Void) as AnyObject
        do {
            let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
            XCTAssertNil(hookContext)
            XCTAssertTrue(false)
        } catch SwiftHookError.internalError(file: let file, line: let line) {
            XCTAssertTrue(file.hasSuffix("\(HookContext.self).swift"))
            XCTAssertEqual(line, InternalErrorLineMethod)
        } catch {
            XCTAssertNil(error)
        }
        XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
    }
    
    // MARK: All instances & before
    
    func testAllInstancesBefore() {
        do {
            let contextCount = HookContext.debugToolsGetAllHookContext().count
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let targetClass = TestObject.self
                let selector = #selector(TestObject.execute(closure:))
                let mode: HookMode = .before
                let closure = {
                    XCTAssertEqual(result, [])
                    result.append(1)
                    } as @convention(block) () -> Void as AnyObject
                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTAssertEqual(result, [1])
                    result.append(2)
                }
                XCTAssertEqual(result, [1, 2])
                
                // cancel
                
                XCTAssertTrue(hookContext.cancelHook())
                result.removeAll()
            }
            
            // test cancel
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testAllInstancesBeforeCheckArguments() {
        do {
            let contextCount = HookContext.debugToolsGetAllHookContext().count
            let test = TestObject()
            let argumentA = 77
            let argumentB = 88
            
            try autoreleasepool {
                // hook
                let targetClass = TestObject.self
                let selector = #selector(TestObject.sumFunc(a:b:))
                let mode: HookMode = .before
                let closure = { a, b in
                    XCTAssertEqual(argumentA, a)
                    XCTAssertEqual(argumentB, b)
                    } as @convention(block) (Int, Int) -> Void as AnyObject
                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                let result = test.sumFunc(a: argumentA, b: argumentB)
                XCTAssertEqual(result, argumentA + argumentB)
                
                // cancel
                XCTAssertTrue(hookContext.cancelHook())
            }
            
            // test cancel
            let result = test.sumFunc(a: argumentA, b: argumentB)
            XCTAssertEqual(result, argumentA + argumentB)
            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: All instances & after
    
    func testAllInstancesAfter() {
        do {
            let contextCount = HookContext.debugToolsGetAllHookContext().count
            let test = TestObject()
            var result = [Int]()
            
            try autoreleasepool {
                // hook
                let targetClass = TestObject.self
                let selector = #selector(TestObject.execute(closure:))
                let mode: HookMode = .after
                let closure = {
                    XCTAssertEqual(result, [2])
                    result.append(1)
                    } as @convention(block) () -> Void as AnyObject
                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
                
                // test hook
                XCTAssertEqual(result, [])
                test.execute {
                    XCTAssertEqual(result, [])
                    result.append(2)
                }
                XCTAssertEqual(result, [2, 1])
                
                // cancel
                
                XCTAssertTrue(hookContext.cancelHook())
                result.removeAll()
            }
            
            // test cancel
            test.execute {
                XCTAssertEqual(result, [])
                result.append(2)
            }
            XCTAssertEqual(result, [2])
            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    // MARK: All instances & instead
    
    // TODO:
    func testAllInstancesInstead() {
//        do {
//            let contextCount = HookContext.debugToolsGetAllHookContext().count
//            let test = TestObject()
//            
//            try autoreleasepool {
//                // hook
//                let targetClass = TestObject.self
//                let selector = #selector(TestObject.sumFunc(a:b:))
//                let mode: HookMode = .instead
//                let closure = { original, a, b in
//                    let result = original(a, b)
//                    XCTAssertEqual(result, a + b)
//                    return a * b
//                    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int as AnyObject
//                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
//                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
//                
//                // test hook
//                let result = test.sumFunc(a: 3, b: 4)
//                XCTAssertEqual(result, 3 * 4)
//                
//                // cancel
//                XCTAssertTrue(hookContext.cancelHook())
//            }
//            
//            // test cancel
//            let result = test.sumFunc(a: 6, b: 7)
//            XCTAssertEqual(result, 6 + 7)
//            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
//        } catch {
//            XCTAssertNil(error)
//        }
        
//        do {
//            let contextCount = HookContext.debugToolsGetAllHookContext().count
//            let test = TestObject()
//            var result = [Int]()
//
//            try autoreleasepool {
//                // hook
//                let targetClass = TestObject.self
//                let selector = #selector(TestObject.execute(closure:))
//                typealias ExecuteType = () -> Void
//                let mode: HookMode = .instead
//                let closure = { original, arg in
//                    XCTAssertEqual(result, [])
//                    result.append(1)
//                    original(arg)
//                    result.append(3)
//                    } as @convention(block) ((ExecuteType) -> Void, ExecuteType) -> Void as AnyObject
//                let hookContext = try HookContext.hook(targetClass: targetClass, selector: selector, mode: mode, hookClosure: closure)
//                XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount + 1)
//
//                // test hook
//                XCTAssertEqual(result, [])
//                test.execute {
//                    XCTAssertEqual(result, [])
//                    result.append(2)
//                }
//                XCTAssertEqual(result, [1, 2, 3])
//
//                // cancel
//
//                XCTAssertTrue(hookContext.cancelHook())
//                result.removeAll()
//            }
//
//            // test cancel
//            test.execute {
//                XCTAssertEqual(result, [])
//                result.append(2)
//            }
//            XCTAssertEqual(result, [2])
//            XCTAssertEqual(HookContext.debugToolsGetAllHookContext().count, contextCount)
//        } catch {
//            XCTAssertNil(error)
//        }
    }
    
}
