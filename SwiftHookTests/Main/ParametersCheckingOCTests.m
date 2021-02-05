//
//  ParametersCheckingOCTests.m
//  SwiftHookTests
//
//  Created by Wang Ya on 1/30/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;

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

@end
