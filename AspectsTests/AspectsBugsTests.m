//
//  ClassBeforeTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 11/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"

@interface AspectsBugsTests : XCTestCase

@end

@implementation AspectsBugsTests

// Aspects don't support this
- (void)testSupportClassMethod
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(classSimpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);

    XCTAssert(triggered == NO);
    [TestObject classSimpleMethod];
    XCTAssert(triggered == YES);

    XCTAssert([token remove] == YES);
}

// Aspects bug.
- (void)testHookSuperAndChild
{
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info){
    } error:&error];
    XCTAssert(error == nil);
    XCTAssert([token remove] == YES);


    token = [SuperTestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
    } error:&error];
    XCTAssert(error == nil);

    TestObject *obj2 = [[TestObject alloc] init];
    [obj2 simpleMethod];

    XCTAssert([token remove] == YES);
}

// Aspects bug.
- (void)testOneTimeAndNormalAtSameTime
{
    NSError *error = nil;
    __block BOOL triggered1 = NO;
    __block BOOL triggered2 = NO;
    
    id<AspectToken> token1 = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info){
        triggered1 = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    id<AspectToken> token2 = [TestObject aspect_hookSelector:@selector(simpleMethod) withOptions:AspectPositionAfter | AspectOptionAutomaticRemoval usingBlock:^(id<AspectInfo> info){
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

@end
