//
//  InstanceBeforeTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"

@interface InstanceBeforeTests : XCTestCase

@end

@implementation InstanceBeforeTests

- (void)testTriggered
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
}

- (void)testOrder
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        XCTAssert(executed == NO);
    } error:&error];
    XCTAssert(error == nil);
    
    [obj methodWithExecutedBlock:^{
        executed = YES;
    }];
    XCTAssert(executed == YES);
}

- (void)testMultipleTimes
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
}

- (void)testOneTime
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore | AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == NO);
}

- (void)testCancel
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    id<AspectToken> token = [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
    
    triggered = NO;
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
    
    BOOL removed = [token remove];
    XCTAssert(removed == YES);
    
    triggered = NO;
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == NO);
}

- (void)testNoAffectToOtherInstance
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered == YES);
    
    TestObject *obj2 = [[TestObject alloc] init];
    triggered = NO;
    [obj2 methodWithExecutedBlock:nil];
    XCTAssert(triggered == NO);
}

- (void)testHookTwice
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered1 = NO;
    __block BOOL triggered2 = NO;
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered1 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    [obj aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered2 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered1 == NO);
    XCTAssert(triggered2 == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(triggered1 == YES);
    XCTAssert(triggered2 == YES);
}

@end
