[中文](Documents/README.zh-Hans.md)

# What is SwiftHook?

A secure, simple, and efficient Swift/Objective-C hook library that dynamically modifies the methods of a specific object or all objects of a class. It supports both Swift and Objective-C and has excellent compatibility with Key-Value Observing (KVO).

It’s based on Objective-C runtime and [libffi](https://github.com/libffi/libffi).

# How to use SwiftHook

1. Call the hook closure **before** executing **specified instance**’s method.

```swift
class TestObject { // No need to inherit from NSObject.
    // Use `@objc` to make this method accessible from Objective-C
    // Using `dynamic` tells Swift to always refer to Objective-C dynamic dispatch
    @objc dynamic func testMethod() {
        print("Executing `testMethod`")
    }
}

let obj = TestObject()

let token = try ObjectHook(obj).hookBefore(#selector(TestObject.testMethod)) {
    print("Before executing `testMethod`")
}

obj.testMethod()
token.cancelHook() // cancel the hook
```

2. Call the hook closure **after** executing **specified instance**'s method and get the parameters.

```swift
class TestObject {
    @objc dynamic func testMethod(_ parameter: String) {
        print("Executing `testMethod` with parameter: \(parameter)")
    }
}

let obj = TestObject()

let token = try ObjectHook(obj).hookAfter(#selector(TestObject.testMethod(_:)), closure: { obj, sel, parameter in
    print("After executing `testMethod` with parameter: \(parameter)")
} as @convention(block) ( // Using `@convention(block)` to declares a Swift closure as an Objective-C block
    AnyObject, // `obj` Instance
    Selector, // `testMethod` Selector
    String // first parameter
) -> Void // return value
)

obj.testMethod("ABC")
token.cancelHook() // cancel the hook
```

3. Totally override the mehtod for **specified instance**.

```swift
class Math {
    @objc dynamic func double(_ number: Int) -> Int {
        let result = number * 2
        print("Executing `double` with \(number), result is \(result)")
        return result
    }
}

let math = Math()

try ObjectHook(math).hook(#selector(Math.double(_:)), closure: { original, obj, sel, number in
    print("Before executing `double`")
    let originalResult = original(obj, sel, number)
    print("After executing `double`, got result \(originalResult)")
    print("Triple the number!")
    return number * 3
} as @convention(block) (
    (AnyObject, Selector, Int) -> Int,  // original method block
    AnyObject, // `math` Instance
    Selector, // `sum` Selector
    Int // number
) -> Int // return value
)

let number = 3
let result = math.double(number)
print("Double \(number), got \(result)")
```

4. Call the hook closure **before** executing the method for **all instances of the class**.

```swift
class TestObject {
    @objc dynamic func testMethod() {
        print("Executing `testMethod`")
    }
}

let token = try hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.testMethod)) {
    print("Before executing `testMethod`")
}

let obj = TestObject()
obj.testMethod()
token.cancelHook() // cancel the hook
```

5. Call the hook closure **before** executing the **class method**.

```swift
class TestObject {
    @objc dynamic class func testClassMethod() {
        print("Executing `testClassMethod`")
    }
    @objc dynamic static func testStaticMethod() {
        print("Executing `testStaticMethod`")
    }
}

try hookClassMethodBefore(targetClass: TestObject.self, selector: #selector(TestObject.testClassMethod)) {
    print("Before executing `testClassMethod`")
}
TestObject.testClassMethod()

try hookClassMethodBefore(targetClass: TestObject.self, selector: #selector(TestObject.testStaticMethod)) {
    print("Before executing `testStaticMethod`")
}
TestObject.testStaticMethod()
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

- iOS 12.0+, MacOS 10.13+ (Unverified for tvOS, watchOS)
- Xcode 15.1+
- Swift 5.0+
