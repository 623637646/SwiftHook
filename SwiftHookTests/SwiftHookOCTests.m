//
//  OCTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 22/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveCTestObject.h"
@import SwiftHook;
#import <SwiftHookTests-Swift.h>

@interface SwiftHookOCTests : XCTestCase

@end

@implementation SwiftHookOCTests

// Perform the hook closure before executing specified instance's method.
- (void)testSingleHookBefore
{
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    NSError *error = nil;
    OCToken *token = [object sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) error:&error closure:^{
        NSLog(@"hooked");
    }];
    XCTAssertNil(error);
    [object noArgsNoReturnFunc];
    [token cancelHook];
}

// Perform the hook closure after executing specified instance's method. And get the parameters.
- (void)testSingleHookAfterWithArguments
{
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    NSError *error = nil;
    OCToken *token = [object sh_hookAfterSelector:@selector(sumFuncWithA:b:) closure:^void (NSObject *object, SEL selector, NSInteger a, NSInteger b){
        NSLog(@"arg1 is %ld", a); // arg1 is 3
        NSLog(@"arg2 is %ld", b); // arg2 is 4
    } error:&error];
    XCTAssertNil(error);
    [object sumFuncWithA:3 b:4];
    [token cancelHook];
}

// Totally override the mehtod for specified instance. You can call original with the same parameters or different parameters. Don't even call the original method if you want.
- (void)testSingleHookInstead
{
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    NSError *error = nil;
    OCToken *token = [object sh_hookInsteadWithSelector:@selector(sumFuncWithA:b:) closure:^NSInteger (NSInteger(^original)(NSObject *object, SEL selector, NSInteger a, NSInteger b), NSObject *object, SEL selector, NSInteger a, NSInteger b){
        // get the arguments of the function
        NSLog(@"arg1 is %ld", a); // arg1 is 3
        NSLog(@"arg2 is %ld", b); // arg2 is 4
        
        // run original function
        NSInteger result = original(object, selector, a, b); // Or change the parameters: let result = original(-1, -2)
        NSLog(@"original result is %ld", result);
        return 9;
    } error:&error];
    XCTAssertNil(error);
    NSInteger result = [object sumFuncWithA:3 b:4];
    NSLog(@"hooked result is %ld", result); // result = 9
    [token cancelHook];
}

// Perform the hook closure before executing the method of all instances of the class.
- (void)testAllInstances
{
    NSError *error = nil;
    OCToken *token = [ObjectiveCTestObject sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) error:&error closure:^{
        NSLog(@"hooked");
    }];
    XCTAssertNil(error);
    [[[ObjectiveCTestObject alloc] init] noArgsNoReturnFunc];
    [token cancelHook];
}

// Perform the hook closure before executing the class method.
- (void)testClassMethod
{
    NSError *error = nil;
    OCToken *token = [ObjectiveCTestObject sh_hookClassMethodBeforeSelector:@selector(classNoArgsNoReturnFunc) error:&error closure:^{
        NSLog(@"hooked");
    }];
    XCTAssertNil(error);
    [ObjectiveCTestObject classNoArgsNoReturnFunc];
    [token cancelHook];
}

// MARK: Advanced usage

// Perform the hook closure before executing the instance dealloc method. This API only works for NSObject.
- (void)testSingleHookBeforeDeallocForNSObject
{
    @autoreleasepool {
        NSError *error = nil;
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        [object sh_hookDeallocBeforeAndReturnError:&error closure:^{
            NSLog(@"released!");
        }];
        XCTAssertNil(error);
    }
}

// Perform hook closure after executing the instance dealloc method. This isn't using runtime. Just add a "Tail" to the instance. The instance is the only object retaining "Tail" object. So when the instance releasing. "Tail" know this event. This API can work for NSObject and pure Swift object.
- (void)testSingleHookAfterDeallocByTail
{
    @autoreleasepool {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        [object sh_hookDeallocAfterByTailAndReturnError:&error closure:^{
            NSLog(@"released!");
        }];
        XCTAssertNil(error);
    }
}

// Totally override the dealloc mehtod for specified instance. Have to call original to avoid memory leak. This API only works for NSObject.
- (void)testSingleHookInsteadDeallocForNSObject
{
    @autoreleasepool {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        [object sh_hookDeallocInsteadAndReturnError:&error closure:^(void (^original)(void)) {
            NSLog(@"before release!");
            original(); // have to call original "dealloc" to avoid memory leak!!!
            NSLog(@"released!");
        }];
        XCTAssertNil(error);
    }
}

// Perform the hook closure before executing the dealloc method of all instances of the class. This API only works for NSObject.
- (void)testAllInstancesHookBeforeDeallocForNSObject
{
    NSError *error = nil;
    [UIViewController sh_hookDeallocBeforeAndReturnError:&error closure:^{
        NSLog(@"released!");
    }];
    XCTAssertNil(error);
    @autoreleasepool {
        UIViewController *vc = [[UIViewController alloc] init];
        NSLog(@"Init a vc %@", vc);
    }
}

@end
