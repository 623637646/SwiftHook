//
//  ParametersCheckingOCTests.m
//  SwiftHookTests
//
//  Created by Wang Ya on 1/30/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;
#import "ObjectiveCTestObject.h"

@interface MyURL88000876545 : NSURL
@end
@implementation MyURL88000876545
@end

@interface MyConstClass : NSObject
@end

@implementation MyConstClass
- (NSObject *const*)myMethod1:(NSObject *const*)p
{
    return p;
}

- (const char *)myMethod2:(const char *)p
{
    return p;
}
@end

@interface ParametersCheckingOCTests : XCTestCase

@end

@implementation ParametersCheckingOCTests

- (void)test_SwiftHookError_hookKVOUnsupportedInstance {
    [self utilities_test_obj:@"123"];
    [self utilities_test_obj:[[NSString alloc] initWithFormat:@"1233243242423432432432423432424242423324234"]];
    [self utilities_test_obj:[[NSMutableString alloc] initWithFormat:@"1233243242423432432432423432424242423324234"]];
    [self utilities_test_obj:@[]];
    [self utilities_test_obj:@[@1]];
    [self utilities_test_obj:@[@1, @2]];
    [self utilities_test_obj:[@[@1, @2] mutableCopy]];
    [self utilities_test_obj:@{@"key": @1}];
    [self utilities_test_obj:@{@"key1": @1, @"key2": @2}];
    [self utilities_test_obj:[[NSSet alloc] init]];
    [self utilities_test_obj:[[NSSet alloc] initWithObjects:@1, nil]];
    [self utilities_test_obj:[[NSSet alloc] initWithObjects:@1, @2, nil]];
    [self utilities_test_obj:[[NSMutableSet alloc] init]];
    [self utilities_test_obj:[[NSMutableSet alloc] initWithObjects:@1, nil]];
    [self utilities_test_obj:[[NSMutableSet alloc] initWithObjects:@1, @2, nil]];
    [self utilities_test_obj:[[NSOrderedSet alloc] init]];
    [self utilities_test_obj:[[NSOrderedSet alloc] initWithObject:@1]];
    [self utilities_test_obj:[[NSOrderedSet alloc] initWithObjects:@1, @2, nil]];
    [self utilities_test_obj:[[NSMutableOrderedSet alloc] init]];
    [self utilities_test_obj:[[NSMutableOrderedSet alloc] initWithObject:@1]];
    [self utilities_test_obj:[[NSMutableOrderedSet alloc] initWithObjects:@1, @2, nil]];
    [self utilities_test_obj:[[NSURL alloc] initWithString:@"https://www.google.com"]];
    [self utilities_test_obj:[[MyURL88000876545 alloc] initWithString:@"https://www.google.com"]];
    [self utilities_test_obj:[[NSTimer alloc] initWithFireDate:[[NSDate alloc] init] interval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
    }]];
}

- (void)utilities_test_obj:(NSObject *)obj {
    NSError *error = nil;
    OCToken *token = [obj sh_hookAfterSelector:@selector(isEqual:) error:&error closure:^{
    }];
    XCTAssertNil(token);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 11);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
}

- (void)test_const_special_cases_parameters {
    NSError *error = nil;
    [MyConstClass sh_hookInsteadWithSelector:@selector(myMethod1:) closure:
     ^(NSObject *const*(^original)(NSObject *object, SEL selector, NSObject *const* parameter),
       NSObject *object, SEL selector, NSObject *const* parameter){
        return original(object, selector, parameter);
    } error:&error];
    XCTAssertNil(error);
}

- (void)test_const_char_pointer {
    NSError *error = nil;
    [MyConstClass sh_hookInsteadWithSelector:@selector(myMethod2:) closure:
     ^(const char *(^original)(NSObject *object, SEL selector, const char *parameter),
       NSObject *object, SEL selector, const char *parameter){
        return original(object, selector, parameter);
    } error:&error];
    XCTAssertNil(error);
}

- (void)test_Error
{
    {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:NSSelectorFromString(@"retain") error:&error closure:^{
            NSLog(@"hooked");
        }];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 1);
        XCTAssertEqualObjects(error.localizedDescription, @"Unsupport to hook current method. Search \"blacklistSelectors\" to see all methods unsupport.");
        [token cancelHook];
    }
    
    {
        NSObject *object = [[NSObject alloc] init];
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) error:&error closure:^{
            NSLog(@"hooked");
        }];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 3);
        XCTAssertEqualObjects(error.localizedDescription, @"Can't find the method by the selector from the class.");
        [token cancelHook];
    }
    
    {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:@selector(setEmptyStruct:) closure:^(BOOL b){
            NSLog(@"hooked");
        } error:&error];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 4);
        XCTAssertEqualObjects(error.localizedDescription, @"The struct of the method's args or return value is empty, This case can't be compatible  with libffi. Please check the parameters or return type of the method.");
        [token cancelHook];
    }
    
    {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:@selector(getEmptyStruct) closure:^(BOOL b){
            NSLog(@"hooked");
        } error:&error];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 4);
        XCTAssertEqualObjects(error.localizedDescription, @"The struct of the method's args or return value is empty, This case can't be compatible  with libffi. Please check the parameters or return type of the method.");
        [token cancelHook];
    }
    
    {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) closure:[[NSObject alloc] init] error:&error];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 5);
        XCTAssertEqualObjects(error.localizedDescription, @"Please check the hook clousre. Is it a standard closure? Does it have keyword @convention(block)?");
        [token cancelHook];
    }
    
    {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) closure:^(BOOL b){
            NSLog(@"hooked");
        } error:&error];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 6);
        XCTAssertEqualObjects(error.localizedDescription, @"For `befor` and `after` mode. The parameters type of the hook closure have to be nil or `@:` or as the same as method's. The closure parameters type is `B`. The method parameters type is `@:`. For more about Type Encodings: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html");
        [token cancelHook];
    }
    
    {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
        void (^hookClosure)(void)  = ^{
            NSLog(@"hooked");
        };
        NSError *error = nil;
        OCToken *token = [object sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) closure:hookClosure error:&error];
        XCTAssertNil(error);
        
        OCToken *token2 = [object sh_hookBeforeSelector:@selector(noArgsNoReturnFunc) closure:hookClosure error:&error];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 7);
        XCTAssertEqualObjects(error.localizedDescription, @"This closure has been hooked with current mode already.");
        
        [token cancelHook];
        [token2 cancelHook];
    }
    
    {
        NSString *obj = [[NSString alloc] initWithFormat:@"123"];
        XCTAssertEqualObjects(NSStringFromClass([obj class]), @"NSTaggedPointerString");
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj)), @"NSTaggedPointerString");
        NSError *error = nil;
        [obj sh_hookBeforeSelector:@selector(length) closure:^{
        } error:&error];
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 10);
        XCTAssertEqualObjects(error.localizedDescription, @"Unsupport to hook instance of NSTaggedPointerString.");
    }
    
}

@end
