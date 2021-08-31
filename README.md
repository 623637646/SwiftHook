[中文](Documents/README.zh-Hans.md)

# What is SwiftHook?

A safe, easy, powerful and efficient hook library for iOS. It supports Swift and Objective-C. It has good compatibility with KVO.

It’s based on iOS runtime and [libffi](https://github.com/libffi/libffi).

# How to use SwiftHook

1. Call the hook closure **before** executing **specified instance**’s method.

```swift
class MyObject { // This class doesn’t have to inherit from NSObject. of course inheriting from NSObject works fine.
    @objc dynamic func sayHello() { // The key words of methods `@objc` and `dynamic` are necessary.
        print("Hello!")
    }
}

do {
    let object = MyObject()
    // WARNING: the object will retain the closure. So make sure the closure doesn't retain the object to avoid memory leak by cycle retain. If you want to access the obeject, please refer to 2nd guide "XXX and get the parameters." below.
    let token = try hookBefore(object: object, selector: #selector(MyObject.sayHello)) {
        print("You will say hello, right?")
    }
    object.sayHello()
    token.cancelHook() // cancel the hook
} catch {
    XCTFail()
}
```

2. Call the hook closure **after** executing **specified instance**'s method and get the parameters.

```swift
class MyObject {
    @objc dynamic func sayHi(name: String) {
        print("Hi! \(name)")
    }
}

do {
    let object = MyObject()
    
    // 1. The first parameter mush be AnyObject or NSObject or YOUR CLASS (If it's YOUR CLASS. It has to inherits from NSObject, otherwise will build error with "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'").
    // 2. The second parameter mush be Selector.
    // 3. The rest parameters are the same as the method's.
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
```

3. Totally override the mehtod for **specified instance**.

```swift
class MyObject {
    @objc dynamic func sum(left: Int, right: Int) -> Int {
        return left + right
    }
}

do {
    let object = MyObject()
    
    // 1. The first parameter mush be an closure. This closure means original method. The closure's parameters and return type are the same with the original method's. 
    // 2. The rest parameters are the same with the original method's.
    // 3. The return type mush be the same with original method's.
    let hookClosure = {original, object, selector, left, right in
        let result = original(object, selector, left, right)
        // You may call original with the different parameters: let result = original(object, selector, 12, 27).
        // You also may change the object and selector if you want. You don't even have to call the original method if needed.
        print("\(left) + \(right) equals \(result)")
        return left * right // Changing the result
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
```

4. Call the hook closure **before** executing the method for **all instances of the class**.

```swift
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
```

5. Call the hook closure **before** executing the **class method**.

```swift
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
```

6. [Hooking the dealloc method](SwiftHookTests/SwiftAPITests/HookAllInstancesTests.swift#L252)
7. [Hooking only once (Cancel the hook once triggered)](SwiftHookTests/SwiftAPITests/HookOnceTests.swift)
8. [Using in Objective-C](SwiftHookTests/OCAPITests)

# How to integrate SwiftHook?

**SwiftHook** can be integrated by [cocoapods](https://cocoapods.org/). 

```
pod 'EasySwiftHook'
```

Or use Swift Package Manager. SPM is supported from **3.2.0**. Make sure your Xcode is greater than 12.5, otherwise it compiles error.

# [Performance](Documents/PERFORMANCE.md)

Comparing with [Aspects](https://github.com/steipete/Aspects) (respect to Aspects).

* Hook with Before and After mode for all instances, SwiftHook is **13 - 17 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3 - 5 times** faster than Aspects.
* Hook with Before and After mode for specified instances, SwiftHook is **4 - 5 times** faster than Aspects.
* Hook with Instead mode for specified instances, SwiftHook is **2 - 4 times** faster than Aspects.

# Compatibility with KVO

SwiftHook is full compatible with KVO from 3.0.0 version.
For more test cases: [Here](SwiftHookTests/Advanced/CompatibilityTests.swift)

# We already have great [Aspects](https://github.com/steipete/Aspects). Why do I create SwiftHook?

1. Aspects has some bugs. [Click here for test code](SwiftHookTests/AspectsTests/AspectsErrorTests.m).
2. Aspects doesn’t support Swift with instead mode in some cases. [Click here for test code](SwiftHookTests/AspectsTests/AspectsSwiftTests.swift).
3. Aspects’s API is not friendly for Swift.
4. Aspects doesn’t support Swift object which is not based on NSObject.
5. Aspects is based on *message forward*. This performance is not good.
6. Aspects are no longer maintained. Author said: “**STRICTLY DO NOT RECOMMEND TO USE Aspects IN PRODUCTION CODE**”
7. Aspects is not compatible with KVO.

BTW, **Respect to Aspects!**

# Requirements

- iOS 10.0+ (Unverified for macOS, tvOS, watchOS)
- Xcode 11+
- Swift 5.0+
