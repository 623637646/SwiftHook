//
//  PerformanceTests.m
//  PerformanceTests
//
//  Created by Yanni Wang on 26/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import Aspects;
@import SwiftHook;

NSInteger measureCount = 100000;

@interface TestObject : NSObject
- (void)emptyMethod;
@end
@implementation TestObject
- (void)emptyMethod
{
}
@end

// WARNING: Swift is very slow then Objective-C in Debug mode. So this test case should be run under release mode! Refer to: https://stackoverflow.com/q/61998649/9315497

@interface PerformanceTests : XCTestCase
@end

@implementation PerformanceTests

- (void)testHookBeforeForAllInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    
    id<AspectToken> aspectsToken = [TestObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionBefore) usingBlock:^(id<AspectInfo> params){
    } error:NULL];
    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [SwiftHookOCBridge ocHookBeforeTargetClass:TestObject.class selector:@selector(emptyMethod) error:NULL closure:^{
    }];
    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with Befre mode for all instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
}

- (void)testHookInsteadForAllInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    
    id<AspectToken> aspectsToken = [TestObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionInstead) usingBlock:^(id<AspectInfo> params){
        [[params originalInvocation] invoke];
    } error:NULL];
    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [SwiftHookOCBridge ocHookInsteadWithTargetClass:TestObject.class selector:@selector(emptyMethod) closure:^(void(^original)(void)){
        original();
    } error:NULL];
    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with Instead mode for all instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
}

- (void)testHookAfterForSingleInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    
    id<AspectToken> aspectsToken = [testObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionAfter) usingBlock:^(id<AspectInfo> params){
    } error:NULL];
    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [SwiftHookOCBridge ocHookAfterObject:testObject selector:@selector(emptyMethod) error:NULL closure:^{
    }];
    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with After mode for single instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
}

- (void)testHookInsteadForSingleInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    
    id<AspectToken> aspectsToken = [testObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionInstead) usingBlock:^(id<AspectInfo> params){
        [[params originalInvocation] invoke];
    } error:NULL];
    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [SwiftHookOCBridge ocHookInsteadWithObject:testObject selector:@selector(emptyMethod) closure:^(void(^original)(void)){
        original();
    } error:NULL];
    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with Instead mode for single instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
}

#pragma mark - utilities

- (NSTimeInterval)executionTimeWithObject:(TestObject *)testObject
{
    NSDate *start = [NSDate date];
    for (int i = 0; i < measureCount; i++) {
        [testObject emptyMethod];
    }
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:start];
    return time;
}

- (void)log:(NSString *)title nonHookTime:(NSTimeInterval)nonHookTime aspectsTime:(NSTimeInterval)aspectsTime swiftHookTime:(NSTimeInterval)swiftHookTime
{
    NSMutableString *log = [[NSMutableString alloc] init];
    [log appendString:@"\n----------------------------------------------------------\n\n"];
    [log appendFormat:@"Case: %@\n", title];
    [log appendFormat:@"%ld times running\n", measureCount];
    [log appendFormat:@"Cost %0.6fs for non-hook\n", nonHookTime];
    [log appendFormat:@"Cost %0.6fs for Aspects\n", aspectsTime];
    [log appendFormat:@"Cost %0.6fs for SwiftHook\n", swiftHookTime];
    [log appendFormat:@"SwiftHook is %0.2f times faster than Aspects (%@)\n", aspectsTime / swiftHookTime, title];
    [log appendFormat:@"SwiftHook takes %0.2f times longer than Non-Hook\n\n", swiftHookTime / nonHookTime];
    [log appendString:@"----------------------------------------------------------"];
    NSLog(@"%@", log);
}

@end
