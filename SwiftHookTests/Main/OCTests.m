//
//  OCTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 22/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveCTestObject.h"
@import SwiftHook;
#import <SwiftHookTests-Swift.h>

@interface OCTests : XCTestCase

@end

@implementation OCTests

- (void)tearDown
{
    [CleanUpOCBridge oc_debug_cleanUp];
}

- (void)testOCAPI1
{
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    OCToken *token = [SwiftHookOCBridge ocHookAfterObject:object selector:@selector(noArgsNoReturnFunc) error:NULL closure:^{
        NSLog(@"Hooked!");
    }];
    [object noArgsNoReturnFunc];
    [token cancelHook];
}

- (void)testOCAPI2
{
    __block BOOL executed = NO;
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    OCToken *token = [SwiftHookOCBridge ocHookAfterObject:object selector:@selector(setNumber:) error:NULL closure:^{
        executed = YES;
    }];
    XCTAssertFalse(executed);
    [object setNumber:99];
    XCTAssertTrue(executed);
    
    executed = NO;
    [token cancelHook];
    [object setNumber:100];
    XCTAssertFalse(executed);
}

@end
