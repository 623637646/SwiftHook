# What is this?

This is a framework to hook in Swift and Objective C by iOS runtime and [libffi](https://github.com/libffi/libffi).

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
