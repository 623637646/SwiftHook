# What is this?

A safe, easy, powerful and efficient hook framework for iOS (Support Swift and Objective-C).

It’s based on iOS runtime and [libffi](https://github.com/libffi/libffi).

# How to install

You can integrate **SwiftHook** with [cocoapods](https://cocoapods.org/). 

```
pod 'EasySwiftHook'
```

# How to use

### 1. Call the hook closure **before** executing **specified instance**’s method.

```swift
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
```

### 2. Call the hook closure **after** executing **specified instance**'s method. And get the parameters.

```swift
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
```

### 3. Totally override the mehtod for **specified instance**.

```swift
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
```

### 4. Call the hook closure **before** executing the method of **all instances of the class**.

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

### 5. Call the hook closure **before** executing the **class method**.

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

### 6. [Using in Objective-C](SwiftHookTests/SwiftHookOCTests.m)

### 7. [Hook dealloc](SwiftHookTests/SwiftHookTests.swift#L87)

# [Performance](Documents/PERFORMANCE.md)

Compared with [Aspects](https://github.com/steipete/Aspects) (respect to Aspects).

* Hook with Before and After mode for all instances, SwiftHook is **13 - 17 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3 - 5 times** faster than Aspects.
* Hook with Before and After mode for specified instances, SwiftHook is **4 - 5 times** faster than Aspects.
* Hook with Instead mode for specified instances, SwiftHook is **2 - 4 times** faster than Aspects.

# We already have great [Aspects](https://github.com/steipete/Aspects). Why do I created SwiftHook?

1. Aspects has some bugs. [Click here for test code](SwiftHookTests/AspectsTests/AspectsErrorTests.m).
2. Aspects doesn’t support Swift with instead mode in some cases. [Click here for test code](SwiftHookTests/AspectsTests/AspectsSwiftTests.swift).
3. Aspects’s API is not friendly for Swift.
4. Aspects doesn’t support Swift object which is not based on NSObject.
5. Aspects is based on *message forward*. This performance is not good.
6. Aspects are no longer maintained. Author said: “**STRICTLY DO NOT RECOMMEND TO USE Aspects IN PRODUCTION CODE**”

BTW, **Respect to Aspects!**

# How it works?

1. What is [libffi](https://github.com/libffi/libffi).? 
    1. Call C function at runtime.
    2. Create closure (IMP) at runtime.
2. [SwiftHook’s logic](https://docs.google.com/drawings/d/13JHfInydNK-2CKLfVb63H2lRMJ3mF5rF6d4wkw7EPSs/edit?usp=sharing).

# Requirements

- iOS 10.0+ (Unverified for macOS, tvOS, watchOS)
- Xcode 11+
- Swift 5.0+
