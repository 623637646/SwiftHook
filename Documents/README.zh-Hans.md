# 这是什么？

一个安全，简单，强大并高效的 iOS hook 库（支持 Swift 和 Objective-C，兼容KVO）。

它基于 iOS runtime 和 [libffi](https://github.com/libffi/libffi)。

# 如何使用？

1. hook某个实例的某个方法，在目标方法执行之前调用 hook 闭包。

```swift
class MyObject { // 这个 Class 不用继承自 NSObject。当然，继承自 NSObject 也没问题。
    @objc dynamic func sayHello() { // 关键字 `@objc` 和 `dynamic` 不可以省略。
        print("Hello!")
    }
}

do {
    let object = MyObject()
    // 警告: 这个 object 会强引用 hook 的闭包. 所以为了避免循环引用导致内存泄漏，请确保 hook closure 不会强引用 object。 如果你想要在 hook closure 里访问object，请参考教程的第二步。
    let token = try hookBefore(object: object, selector: #selector(MyObject.sayHello)) {
        print("You will say hello, right?")
    }
    object.sayHello()
    token.cancelHook() // 取消 hook。
} catch {
    XCTFail()
}
```

2. hook某个实例的某个方法，在目标方法执行之后调用 hook 闭包，并且获取方法的参数。


```swift
class MyObject {
    @objc dynamic func sayHi(name: String) {
        print("Hi! \(name)")
    }
}

do {
    let object = MyObject()
    
    // 1. 第一个参数必须是 AnyObject 或者 NSObject 或者“你的Class”（如果第一个参数是“你的Class”，那么“你的Class”必须继承自 NSObject。否则会有编译错误 "XXX is not representable in Objective-C, so it cannot be used with '@convention(block)'"）
    // 2. 第二个参数必须是 Selector
    // 3. 剩下的参数和方法的参数保持一致。
    // 4. 如果 hook模式是 `before`和`after`，那么返回值必须是Void。
    // 5. 关键字 `@convention(block)` 不能省略。
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

3. hook某个实例的某个方法，用 hook 闭包完全取代目标方法。

```swift
class MyObject {
    @objc dynamic func sum(left: Int, right: Int) -> Int {
        return left + right
    }
}

do {
    let object = MyObject()
    
    // 1. 第一个参数必须是一个闭包。这个闭包代表原来方法的实现。此闭包的参数和返回值必须和目标方法一致。
    // 2. 剩下的参数必须和目标方法的参数类型一致。
    // 3. 返回值必须和目标方法的返回值类型一致。
    let hookClosure = {original, object, selector, left, right in
        let result = original(object, selector, left, right)
        // 你可以用自定义的参数调用原实现。 let result = original(object, selector, 12, 27).
        // 如果你愿意，也可以修改 object 和 selector。如果需要，甚至可以不调用原实现。
        print("\(left) + \(right) equals \(result)")
        return left * right // 可以修改返回值
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

4. hook某个类的所有实例的某个方法，在目标方法执行之前调用 hook 闭包。


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

5. hook某个类的某个类方法，在目标方法执行之前调用 hook 闭包。

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

6. [在 Objective-C 中使用](../SwiftHookTests/SwiftHookOCTests.m)

7. [Hook dealloc 方法](../SwiftHookTests/SwiftHookTests.swift#L146)

# 怎么集成？

使用 [cocoapods](https://cocoapods.org/). 

```
pod 'EasySwiftHook'
```

或者使用 Swift Package Manager。 **3.2.0** 版本之后，SPM被支持。

欢迎提 Pull Request 来支持 carthage 和 Swift Package。

# [性能](../Documents/PERFORMANCE.md)

和 [Aspects](https://github.com/steipete/Aspects) 比较 (向 Aspects 致敬).

* Hook with Before and After mode for all instances, SwiftHook is **13 - 17 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3 - 5 times** faster than Aspects.
* Hook with Before and After mode for specified instances, SwiftHook is **4 - 5 times** faster than Aspects.
* Hook with Instead mode for specified instances, SwiftHook is **2 - 4 times** faster than Aspects.

# KVO兼容性

自 3.0.0 版本以来，完美兼容KVO。
更多测试用例: [Here](../SwiftHookTests/Main/CompatibilityTests.swift)

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

- iOS 10.0+ (Unverified for macOS, tvOS, watchOS)
- Xcode 11+
- Swift 5.0+
