//
//  AspectsTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"

@interface TestObject : NSObject

- (void)someMethod:(BOOL *)executed;

@end

@implementation TestObject

- (void)someMethod:(BOOL *)executed;
{
    if (executed) {
        *executed = YES;
    }
}

@end

@interface AspectsTests : XCTestCase

@end

@implementation AspectsTests

- (void)testNoHook
{
    TestObject *obj = [[TestObject alloc] init];
    BOOL executed = NO;
    [obj someMethod:&executed];
    XCTAssert(executed == YES);
}

- (void)testTriggered
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(someMethod:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj someMethod:NULL];
    XCTAssert(triggered == YES);
}

- (void)testOrder
{
    NSError *error = nil;
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(someMethod:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        XCTAssert(executed == NO);
    } error:&error];
    XCTAssert(error == nil);
    
    [obj someMethod:&executed];
    XCTAssert(executed == YES);
}

@end
