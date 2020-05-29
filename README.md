# What is this?

A safe, easy, powerful and efficient hook framework for iOS (Support Swift and Objective-C).

It’s based on iOS runtime and [libffi](https://github.com/libffi/libffi).

# How to install

You can integrate **SwiftHook** with [cocoapods](https://cocoapods.org/). 

```
pod 'EasySwiftHook'
```

# [How to use](SwiftHookTests/SwiftHookTests.swift)

For example, this is your class

```swift
class MyObject {
    @objc dynamic func noArgsNoReturnFunc() {
    }
    @objc dynamic func sumFunc(a: Int, b: Int) -> Int {
        return a + b
    }
    @objc dynamic class func classMethodNoArgsNoReturnFunc() {
    }
}
```

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **The key words of methods `@objc` and `dynamic` are necessary**

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **The class doesn't have to inherit from NSObject. If the class is written by Objective-C, Just hook it without any more effort**

1. Perform the hook closure before executing specified instance's method.

```swift
let object = MyObject()
let token = try? hookBefore(object: object, selector: #selector(MyObject.noArgsNoReturnFunc)) {
    // run your code
    print("hooked!")
}
object.noArgsNoReturnFunc()
token?.cancelHook() // cancel the hook
```

2. Perform the hook closure after executing specified instance's method. And get the parameters.

```swift
let object = MyObject()
let token = try? hookAfter(object: object, selector: #selector(MyObject.sumFunc(a:b:)), closure: { a, b in
    // get the arguments of the function
    print("arg1 is \(a)") // arg1 is 3
    print("arg2 is \(b)") // arg2 is 4
    } as @convention(block) (Int, Int) -> Void)
_ = object.sumFunc(a: 3, b: 4)
token?.cancelHook() // cancel the hook
```
![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **The key word `@convention(block)` is necessary**

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **For hook at `before` and `after`. The closure's args have to be empty or the same as method. The return type has to be `void`**

3. Totally override the mehtod for specified instance. You can call original with the same parameters or different parameters. Don't even call the original method if you want.

```swift
let object = MyObject()
let token = try? hookInstead(object: object, selector: #selector(MyObject.sumFunc(a:b:)), closure: { original, a, b in
    // get the arguments of the function
    print("arg1 is \(a)") // arg1 is 3
    print("arg2 is \(b)") // arg2 is 4

    // run original function
    let result = original(a, b) // Or change the parameters: let result = original(-1, -2)
    print("original result is \(result)") // result = 7
    return 9
    } as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int)
let result = object.sumFunc(a: 3, b: 4) // result
print("hooked result is \(result)") // result = 9
token?.cancelHook() // cancel the hook
```

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **For hook with `instead`. The closure's first argument has to be a closure which has the same types with the method. The rest args and return type have to be the same as the method.**

4. Perform the hook closure before executing the method of all instances of the class.

```swift
let token = try? hookBefore(targetClass: MyObject.self, selector: #selector(MyObject.noArgsNoReturnFunc)) {
    // run your code
    print("hooked!")
}
MyObject().noArgsNoReturnFunc()
token?.cancelHook() // cancel the hook
```

5. Perform the hook closure before executing the class method.

```swift
let token = try? hookClassMethodBefore(targetClass: MyObject.self, selector: #selector(MyObject.classMethodNoArgsNoReturnFunc)) {
    // run your code
    print("hooked!")
}
MyObject.classMethodNoArgsNoReturnFunc()
token?.cancelHook() // cancel the hook
```

6. Hook in Objective-C

```objective-c
ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
OCToken *token = [SwiftHookOCBridge ocHookAfterObject:object selector:@selector(noArgsNoReturnFunc) error:NULL closure:^{
    NSLog(@"Hooked!");
}];
[object noArgsNoReturnFunc];
[token cancelHook];
```

### Advanced usage

For example, this is your class

```swift
class MyNSObject: NSObject {
    deinit {
        print("deinit executed")
    }
}
```

1. Perform the hook closure before executing the instance dealloc method. This API only works for NSObject.

```swift
let object = MyNSObject()
_ = try? hookDeallocBefore(object: object) {
    print("released!")
}
```

2. Perform hook closure after executing the instance dealloc method. This isn't using runtime. Just add a "Tail" to the instance. The instance is the only object retaining "Tail" object. So when the instance releasing. "Tail" know this event. This API can work for NSObject and pure Swift object.

```swift
let object = MyObject()
_ = try? hookDeallocAfterByTail(object: object) {
    print("released!")
}
```

3. Totally override the dealloc mehtod for specified instance. Have to call original to avoid memory leak. This API only works for NSObject.

```swift
autoreleasepool {
    let object = NSObject()
    _ = try? hookDeallocInstead(object: object) { original in
        print("before release!")
        original() // have to call original "dealloc" to avoid memory leak!!!
        print("released!")
    }
}
```

4. Perform the hook closure before executing the dealloc method of all instances of the class. This API only works for NSObject.

```swift
_ = try? hookDeallocBefore(targetClass: UIViewController.self) {
    print("released!")
}
autoreleasepool {
    _ = UIViewController()
}
```

# [Performance](Documents/PERFORMANCE.md)

Compared with [Aspects](https://github.com/steipete/Aspects) (respect to Aspects).

* Hook with Before and After mode for all instances, SwiftHook is **15 times** faster than Aspects.
* Hook with Instead mode for all instances, SwiftHook is **3.5 times** faster than Aspects.
* Hook with Before and After mode for specified instances, SwiftHook is **4.5 times** faster than Aspects.
* Hook with Instead mode for specified instances, SwiftHook is **1.9 times** faster than Aspects.

# We already have [Aspects](https://github.com/steipete/Aspects). Why do I created SwiftHook?

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

