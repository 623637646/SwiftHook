//
//  AspectsClassTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"

@interface AllInstanceBeforeTests : XCTestCase

@end

@implementation AllInstanceBeforeTests

- (void)testTriggered
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    XCTAssert([token remove] == YES);
}

- (void)testOrder
{
    __block BOOL triggered = NO;
    __block BOOL executed = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(executedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        XCTAssert(triggered == NO);
        XCTAssert(executed == NO);
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];
    [obj executedBlock:^{
        XCTAssert(triggered == YES);
        XCTAssert(executed == NO);
        executed = YES;
    }];
    XCTAssert(executed == YES);
    
    XCTAssert([token remove] == YES);
}

- (void)testMultipleTimes
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];
    
    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    XCTAssert([token remove] == YES);
}

- (void)testOneTime
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore | AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];

    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);

    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == NO);
    
    XCTAssert([token remove] == NO);
}

// Aspects bug.
- (void)testOneTimeAndNormalAtSameTime
{
    NSError *error = nil;
    __block BOOL triggered1 = NO;
    __block BOOL triggered2 = NO;
    
    id<AspectToken> token1 = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered1 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    id<AspectToken> token2 = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionInstead | AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        triggered2 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];
    
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
    
    XCTAssert([token1 remove] == YES);
    XCTAssert([token2 remove] == NO);
}


- (void)testCancel
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];

    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);

    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == YES);

    XCTAssert([token remove] == YES);

    triggered = NO;
    [obj simpleMethod];
    XCTAssert(triggered == NO);
}

- (void)testNoAffectToSuperClassInstance
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    SuperTestObject *obj = [[SuperTestObject alloc] init];

    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == NO);
    
    XCTAssert([token remove] == YES);
}

// Aspects don't support this
- (void)testAffectToChildClassInstance
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [SuperTestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];

    XCTAssert(triggered == NO);
    [obj simpleMethod];
    XCTAssert(triggered == YES);
    
    XCTAssert([token remove] == YES);
}

- (void)testHookTwice
{
    NSError *error = nil;
    __block BOOL triggered1 = NO;
    __block BOOL triggered2 = NO;
    
    id<AspectToken> token1 = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered1 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    id<AspectToken> token2 = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered2 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    TestObject *obj = [[TestObject alloc] init];

    XCTAssert(triggered1 == NO);
    XCTAssert(triggered2 == NO);
    [obj simpleMethod];
    XCTAssert(triggered1 == YES);
    XCTAssert(triggered2 == YES);
    
    XCTAssert([token1 remove] == YES);
    XCTAssert([token2 remove] == YES);
}

@end
