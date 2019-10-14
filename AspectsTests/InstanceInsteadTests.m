//
//  InstanceInsteadTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"
#import <objc/runtime.h>

@interface InstanceInsteadTests : XCTestCase

@end

@implementation InstanceInsteadTests

- (void)testTriggered
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
}

- (void)testMultipleTimes
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == YES);
}

- (void)testOneTime
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead | AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == NO);
}

// Aspects bug.
- (void)testOneTimeAndNormalAtSameTime
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered1 = NO;
    __block BOOL triggered2 = NO;
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered1 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead | AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        triggered2 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered1 == NO);
    XCTAssert(triggered2 == NO);
    [obj simpleMethod];
    XCTAssert(triggered1 == YES);
    XCTAssert(triggered2 == YES);
    
    triggered1 = NO;
    triggered2 = NO;
    [obj simpleMethod];
    XCTAssert(triggered1 == YES);
    XCTAssert(triggered2 == NO);
}

- (void)testCancel
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    id<AspectToken> token = [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    BOOL removed = [token remove];
    XCTAssert(removed == YES);
    
    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == NO);
}

- (void)testNoAffectToOtherInstance
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    TestObject *obj2 = [[TestObject alloc] init];
    triggered = NO;
    [obj2 simpleMethod];
    XCTAssert(triggered == NO);
}

- (void)testSkipOriginal
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(executedBlock:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        
    } error:&error];
    XCTAssert(error == nil);
    
    [obj executedBlock:^{
        executed = YES;
    }];
    XCTAssert(executed == NO);
}

- (void)testCalledOriginal
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(executedBlock:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        [info.originalInvocation invoke];
    } error:&error];
    XCTAssert(error == nil);
    
    [obj executedBlock:^{
        executed = YES;
    }];
    XCTAssert(executed == YES);
}

- (void)testChangedReturnValue
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block NSObject *obj1 = [[NSObject alloc] init];
    __block NSObject *obj2 = [[NSObject alloc] init];
    
    [obj aspect_hookSelector:@selector(returnParameter:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        objc_setAssociatedObject(invocation, _cmd, obj2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [invocation setReturnValue:&obj2];
    } error:&error];
    XCTAssert(error == nil);
    
    id result = [obj returnParameter:obj1];
    XCTAssert(result == obj2);
}

- (void)testHookTwice
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered1 = NO;
    __block BOOL triggered2 = NO;
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered1 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    [obj aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered2 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered1 == NO);
    XCTAssert(triggered2 == NO);
    [obj simpleMethod];
    XCTAssert(triggered1 == YES);
    XCTAssert(triggered2 == YES);
}

@end
