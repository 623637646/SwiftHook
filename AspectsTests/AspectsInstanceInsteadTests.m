//
//  AspectsInstanceInsteadTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"

@interface AspectsInstanceInsteadTests : XCTestCase

@end

@implementation AspectsInstanceInsteadTests

- (void)testTriggered
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(someMethod:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj someMethod:NULL];
    XCTAssert(triggered == YES);
}

- (void)testSkipOriginal
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(someMethod:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        
    } error:&error];
    XCTAssert(error == nil);
    
    [obj someMethod:&executed];
    XCTAssert(executed == NO);
}

- (void)testCalledOriginal
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(someMethod:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        [info.originalInvocation invoke];
    } error:&error];
    XCTAssert(error == nil);
    
    [obj someMethod:&executed];
    XCTAssert(executed == YES);
}

@end
