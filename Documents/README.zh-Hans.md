# 这是什么？

一个安全、简单、高效的 Swift/Objective-C hook库，可以动态修改某个对象的方法或者一个类所有对象的某个方法。 它支持 Swift 和 Objective-C，与 KVO 具有良好的兼容性。

它基于 Objective-C 运行时和 [libffi](https://github.com/libffi/libffi)。

# 如何使用？

1. hook某个实例的某个方法，在目标方法执行之前调用 hook 闭包。

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

2. hook某个实例的某个方法，在目标方法执行之后调用 hook 闭包，并且获取方法的参数。


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

3. hook某个实例的某个方法，用 hook 闭包完全取代目标方法。

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

4. hook某个类的所有实例的某个方法，在目标方法执行之前调用 hook 闭包。


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

5. hook某个类的某个类方法或静态方法，在目标方法执行之前调用 hook 闭包。

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

6. [Hook dealloc 方法](../SwiftHookTests/SwiftAPITests/HookAllInstancesTests.swift#L252)
7. [只 hook 一次](../SwiftHookTests/SwiftAPITests/HookOnceTests.swift)
8. [在 Objective-C 中使用](../SwiftHookTests/OCAPITests)

# 怎么集成？

使用 [cocoapods](https://cocoapods.org/). 

```
pod 'EasySwiftHook'
```

或者使用 Swift Package Manager。 **3.2.0** 版本之后，SPM被支持。确保Xcode的版本大于等于12.5，否则会有编译错误。

# [性能](../Documents/PERFORMANCE.md)

和 [Aspects](https://github.com/steipete/Aspects) 比较 (向 Aspects 致敬).

* Hook with Before and After mode for all instances, SwiftHook is **13 - 17 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3 - 5 times** faster than Aspects.
* Hook with Before and After mode for specified instances, SwiftHook is **4 - 5 times** faster than Aspects.
* Hook with Instead mode for specified instances, SwiftHook is **2 - 4 times** faster than Aspects.

# KVO兼容性

自 3.0.0 版本以来，完美兼容KVO。
更多测试用例: [Here](../SwiftHookTests/Advanced/CompatibilityTests.swift)

# We already have great [Aspects](https://github.com/steipete/Aspects). Why do I created SwiftHook?

1. Aspects has some bugs. [Click here for test code](../SwiftHookTests/AspectsTests/AspectsErrorTests.m).
2. Aspects doesn’t support Swift with instead mode in some cases. [Click here for test code](../SwiftHookTests/AspectsTests/AspectsSwiftTests.swift).
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
