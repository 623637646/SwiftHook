//
//  AspectsTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveCTestObject.h"
#import <objc/runtime.h>
@import Aspects;

@interface AspectsTests : XCTestCase

@end

@implementation AspectsTests

- (void)testClassMethod
{
    NSError *error = nil;
    [object_getClass(ObjectiveCTestObject.class) aspect_hookSelector:@selector(classNoArgsNoReturnFunc) withOptions:AspectPositionAfter usingBlock:^(){
        NSLog(@"");
    } error:&error];
    XCTAssertNil(error);
    
    [ObjectiveCTestObject classNoArgsNoReturnFunc];
}

- (void)testModifyIntReture {
    [self aspect_hookSelector:@selector(getInteger) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        NSInteger integer;
        [invocation invoke];
        [invocation getReturnValue:&integer];
        XCTAssertEqual(integer, 999);
        integer = 333;
        [invocation setReturnValue:&integer];
    } error:NULL];
    NSInteger integer = [self getInteger];
    XCTAssertEqual(integer, 333);
}

- (void)testModifyStringReture {
    [self aspect_hookSelector:@selector(getString) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        NSString *string;
        [invocation invoke];
        [invocation getReturnValue:&string];
        XCTAssertEqual(string, @"zzz");
        NSString *newString = @"kkk";
        [invocation setReturnValue:&newString];
    } error:NULL];
    NSString *string = [self getString];
    XCTAssertEqual(string, @"kkk");
}

- (void)testModifyNumberReture {
    [self aspect_hookSelector:@selector(getNumber) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        NSNumber *number;
        [invocation invoke];
        [invocation getReturnValue:&number];
        XCTAssertEqual(number, @8);
        NSNumber *newNumber = @16;
        [invocation setReturnValue:&newNumber];
    } error:NULL];
    NSNumber *number = [self getNumber];
    XCTAssertEqual(number, @16);
}

- (void)testModifyNSValueReture {
    [self aspect_hookSelector:@selector(getValue) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        __unsafe_unretained NSValue *value;
        [invocation invoke];
        [invocation getReturnValue:&value];
        XCTAssertTrue([value isEqualToValue:[NSValue valueWithCGPoint:CGPointMake(11, 22)]]);
        NSValue *newValue = [NSValue valueWithCGRect:CGRectMake(1, 2, 3, 4)];
        [invocation setReturnValue:&newValue];
    } error:NULL];
    NSValue *value = [self getValue];
    XCTAssertTrue([value isEqualToValue:[NSValue valueWithCGRect:CGRectMake(1, 2, 3, 4)]]);
}

- (void)testModifyRequestReture {
    [self aspect_hookSelector:@selector(getRequest) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        __unsafe_unretained NSURLRequest *request;
        [invocation invoke];
        [invocation getReturnValue:&request];
        XCTAssertEqual(request.URL.absoluteString, @"https://www.google.com");
        NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.facebook.com"]];
        [invocation setReturnValue:&newRequest];
        [invocation retainArguments];
    } error:NULL];
    NSURLRequest *request = [self getRequest];
    XCTAssertEqual(request.URL.absoluteString, @"https://www.facebook.com");
}

- (void)testModifyObjectReture {
    [self aspect_hookSelector:@selector(getTestObject) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        // NSInvocation is not supported on Swfit!
        NSInvocation *invocation = info.originalInvocation;
        // __unsafe_unretained is necessary. otherwise will on EXC_BAD_ACCESS
        __unsafe_unretained ObjectiveCTestObject *testObject;
        [invocation invoke];
        [invocation getReturnValue:&testObject];
        XCTAssertEqual(testObject.number, 999);
        
        ObjectiveCTestObject *newTestObject = [[ObjectiveCTestObject alloc] init];
        newTestObject.number = 333;
        [invocation setReturnValue:&newTestObject];
        
        // solution 1:
        // objc_setAssociatedObject is necessary. otherwise will on EXC_BAD_ACCESS
//        objc_setAssociatedObject(invocation, _cmd, newTestObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // solution 2:
        [invocation retainArguments];
    } error:NULL];
    ObjectiveCTestObject *testObject = [self getTestObject];
    XCTAssertEqual(testObject.number, 333);
}

#pragma mark - test method

- (ObjectiveCTestObject *)getTestObject
{
    ObjectiveCTestObject *testObject = [[ObjectiveCTestObject alloc] init];
    testObject.number = 999;
    return testObject;
}

- (NSInteger)getInteger
{
    return 999;
}

- (NSString *)getString
{
    return @"zzz";
}

- (NSNumber *)getNumber
{
    return @8;
}

- (NSValue *)getValue
{
    return [NSValue valueWithCGPoint:CGPointMake(11, 22)];
}

- (NSURLRequest *)getRequest
{
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]];
}

@end
