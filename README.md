# What is this?

This is a framework to hook methods in Swift and Objective C by iOS runtime and [libffi](https://github.com/libffi/libffi).

# How to install

You can integrate **SwiftHook** with [cocoapods](https://cocoapods.org/). 

```
pod 'EasySwiftHook'
```

# How to use it.

For example, this is your class

```swift
class TestObject {
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

### Hook before executing a function for a single object

```swift
let testObject = TestObject()
let token = try? hookBefore(object: testObject, selector: #selector(TestObject.noArgsNoReturnFunc)) {
    // run your code
    print("hooked!")
}
testObject.noArgsNoReturnFunc()
token?.cancelHook() // cancel the hook
```

### Hook after executing a function for a single object, and get the arguments of the function

```swift
let testObject = TestObject()
let token = try? hookAfter(object: testObject, selector: #selector(TestObject.sumFunc(a:b:)), closure: { a, b in
    // get the arguments of the function
    print("arg1 is \(a)") // arg1 is 3
    print("arg1 is \(b)") // arg1 is 4
} as @convention(block) (Int, Int) -> Void)
_ = testObject.sumFunc(a: 3, b: 4)
token?.cancelHook() // cancel the hook
```
![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **The key word `@convention(block)` is necessary**

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **For hook at `before` and `after`. The closure's args have to be empty or the same as method. The return type has to be `void`**

### Hook a single object to override a function

```swift
let testObject = TestObject()
let token = try? hookInstead(object: testObject, selector: #selector(TestObject.sumFunc(a:b:)), closure: { original, a, b in
    // get the arguments of the function
    print("arg1 is \(a)") // arg1 is 3
    print("arg1 is \(b)") // arg1 is 4
    
    // run original function
    let result = original(a, b)
    print("original result is \(result)") // result = 7
    return a * b
} as @convention(block) ((Int, Int) -> Int, Int, Int) -> Int)
let result = testObject.sumFunc(a: 3, b: 4) // result
print("hooked result is \(result)") // result = 12
token?.cancelHook() // cancel the hook
```

![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) **For hook with `instead`. The closure's first argument has to be a closure which has the same types with the method. The rest args and return type have to be the same as the method.**

### Hook for all instances of a Class

```swift
let token = try? hookBefore(targetClass: TestObject.self, selector: #selector(TestObject.noArgsNoReturnFunc)) {
    // run your code
    print("hooked!")
}
TestObject().noArgsNoReturnFunc()
token?.cancelHook() // cancel the hook
```

### Hook class methods

```swift
let token = try? hookClassMethodBefore(targetClass: TestObject.self, selector: #selector(TestObject.classMethodNoArgsNoReturnFunc)) {
    // run your code
    print("hooked!")
}
TestObject.classMethodNoArgsNoReturnFunc()
token?.cancelHook() // cancel the hook
```

### Hook in Objective-C

```objective-c
ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
OCToken *token = [SwiftHookOCBridge ocHookAfterObject:object selector:@selector(noArgsNoReturnFunc) error:NULL closure:^{
    NSLog(@"Hooked!");
}];
[object noArgsNoReturnFunc];
[token cancelHook];
```

### Advanced usage

Hook before executing `dealloc` for single NSObject.

```swift
autoreleasepool {
    let object = NSObject()
    _ = try? hookDeallocBefore(object: object) {
        print("released!")
    }
}
```

Hook after executing `dealloc` for single object (inclued pure swift object).

```swift
autoreleasepool {
    let object = TestObject()
    _ = try? hookDeallocAfterByTail(object: object) {
        print("released!")
    }
}
```

Hook a single NSObject to override the `dealloc` function.

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

Hook before executing `dealloc` for All NSObject.

```swift
_ = try? hookDeallocBefore(targetClass: UIViewController.self) {
    print("released!")
}
autoreleasepool {
    _ = UIViewController()
}
```

