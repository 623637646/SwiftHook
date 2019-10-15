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

@interface ClassBeforeTests : XCTestCase

@end

@implementation ClassBeforeTests

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

- (void)testOneBug
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

@end
