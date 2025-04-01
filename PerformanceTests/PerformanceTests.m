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
    NSError *error = nil;
    
    id<AspectToken> aspectsToken = [TestObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionBefore) usingBlock:^(id<AspectInfo> params){
    } error:&error];
    XCTAssertNil(error);

    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [TestObject sh_hookBeforeSelector:@selector(emptyMethod) error:&error closure:^{
    }];
    XCTAssertNil(error);

    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with Befre mode for all instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
    XCTAssert(aspectsTime / swiftHookTime > 10 && aspectsTime / swiftHookTime < 30);
}

- (void)testHookInsteadForAllInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    NSError *error = nil;
    
    id<AspectToken> aspectsToken = [TestObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionInstead) usingBlock:^(id<AspectInfo> params){
        [[params originalInvocation] invoke];
    } error:&error];
    XCTAssertNil(error);

    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [TestObject sh_hookInsteadWithSelector:@selector(emptyMethod) closure:^(void(^original)(NSObject *, SEL), NSObject *object, SEL selector){
        original(object, selector);
    } error:&error];
    XCTAssertNil(error);

    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with Instead mode for all instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
    XCTAssert(aspectsTime / swiftHookTime > 3 && aspectsTime / swiftHookTime < 9);
}

- (void)testHookAfterForSingleInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    NSError *error = nil;
    
    id<AspectToken> aspectsToken = [testObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionAfter) usingBlock:^(id<AspectInfo> params){
    } error:&error];
    XCTAssertNil(error);

    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [testObject sh_hookAfterSelector:@selector(emptyMethod) error:&error closure:^{
    }];
    XCTAssertNil(error);

    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with After mode for single instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
    XCTAssert(aspectsTime / swiftHookTime > 3 && aspectsTime / swiftHookTime < 9);
}

- (void)testHookInsteadForSingleInstance {
    TestObject *testObject = [[TestObject alloc] init];
    NSTimeInterval nonHookTime = [self executionTimeWithObject:testObject];
    NSError *error = nil;
    
    id<AspectToken> aspectsToken = [testObject aspect_hookSelector:@selector(emptyMethod) withOptions:(AspectPositionInstead) usingBlock:^(id<AspectInfo> params){
        [[params originalInvocation] invoke];
    } error:&error];
    XCTAssertNil(error);

    NSTimeInterval aspectsTime = [self executionTimeWithObject:testObject];
    XCTAssertTrue([aspectsToken remove]);
    
    OCToken *swiftHookToken = [testObject sh_hookInsteadWithSelector:@selector(emptyMethod) closure:^(void(^original)(NSObject *, SEL), NSObject *object, SEL selector){
        original(object, selector);
    } error:&error];
    XCTAssertNil(error);
    
    NSTimeInterval swiftHookTime = [self executionTimeWithObject:testObject];
    [swiftHookToken cancelHook];
    
    [self log:@"Hook with Instead mode for single instances" nonHookTime: nonHookTime aspectsTime: aspectsTime swiftHookTime: swiftHookTime];
    XCTAssert(aspectsTime / swiftHookTime > 1.5 && aspectsTime / swiftHookTime < 3.5);
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
    [log appendFormat:@"%@ times running\n", @(measureCount)];
    [log appendFormat:@"Cost %0.6fs for non-hook\n", nonHookTime];
    [log appendFormat:@"Cost %0.6fs for Aspects\n", aspectsTime];
    [log appendFormat:@"Cost %0.6fs for SwiftHook\n", swiftHookTime];
    [log appendFormat:@"SwiftHook is %0.2f times faster than Aspects (%@)\n", aspectsTime / swiftHookTime, title];
    [log appendFormat:@"SwiftHook takes %0.2f times longer than Non-Hook\n\n", swiftHookTime / nonHookTime];
    [log appendString:@"----------------------------------------------------------"];
    NSLog(@"%@", log);
}

@end


/**
 Xcode 15.1, iPhone 15 Pro Max Simulator, Chip Apple M2 Max
 
 Test Suite 'All tests' started at 2023-12-31 16:11:30.451.
 Test Suite 'PerformanceTests.xctest' started at 2023-12-31 16:11:30.452.
 Test Suite 'PerformanceTests' started at 2023-12-31 16:11:30.452.
 Test Case '-[PerformanceTests testHookAfterForSingleInstance]' started.

 ----------------------------------------------------------

 Case: Hook with After mode for single instances
 100000 times running
 Cost 0.000246s for non-hook
 Cost 0.254924s for Aspects
 Cost 0.052079s for SwiftHook
 SwiftHook is 4.89 times faster than Aspects (Hook with After mode for single instances)
 SwiftHook takes 211.66 times longer than Non-Hook

 ----------------------------------------------------------
 Test Case '-[PerformanceTests testHookAfterForSingleInstance]' passed (0.338 seconds).
 Test Case '-[PerformanceTests testHookBeforeForAllInstance]' started.

 ----------------------------------------------------------

 Case: Hook with Befre mode for all instances
 100000 times running
 Cost 0.000335s for non-hook
 Cost 0.240454s for Aspects
 Cost 0.013159s for SwiftHook
 SwiftHook is 18.27 times faster than Aspects (Hook with Befre mode for all instances)
 SwiftHook takes 39.28 times longer than Non-Hook

 ----------------------------------------------------------
 Test Case '-[PerformanceTests testHookBeforeForAllInstance]' passed (0.268 seconds).
 Test Case '-[PerformanceTests testHookInsteadForAllInstance]' started.

 ----------------------------------------------------------

 Case: Hook with Instead mode for all instances
 100000 times running
 Cost 0.000234s for non-hook
 Cost 0.248692s for Aspects
 Cost 0.045132s for SwiftHook
 SwiftHook is 5.51 times faster than Aspects (Hook with Instead mode for all instances)
 SwiftHook takes 192.87 times longer than Non-Hook

 ----------------------------------------------------------
 Test Case '-[PerformanceTests testHookInsteadForAllInstance]' passed (0.308 seconds).
 Test Case '-[PerformanceTests testHookInsteadForSingleInstance]' started.

 ----------------------------------------------------------

 Case: Hook with Instead mode for single instances
 100000 times running
 Cost 0.000234s for non-hook
 Cost 0.244987s for Aspects
 Cost 0.104481s for SwiftHook
 SwiftHook is 2.34 times faster than Aspects (Hook with Instead mode for single instances)
 SwiftHook takes 446.48 times longer than Non-Hook

 ----------------------------------------------------------
 Test Case '-[PerformanceTests testHookInsteadForSingleInstance]' passed (0.362 seconds).
 Test Suite 'PerformanceTests' passed at 2023-12-31 16:11:31.729.
      Executed 4 tests, with 0 failures (0 unexpected) in 1.276 (1.277) seconds
 Test Suite 'PerformanceTests.xctest' passed at 2023-12-31 16:11:31.730.
      Executed 4 tests, with 0 failures (0 unexpected) in 1.276 (1.278) seconds
 Test Suite 'All tests' passed at 2023-12-31 16:11:31.730.
      Executed 4 tests, with 0 failures (0 unexpected) in 1.276 (1.279) seconds
 Program ended with exit code: 0
 
 */
