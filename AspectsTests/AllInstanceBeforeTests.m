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

@end
