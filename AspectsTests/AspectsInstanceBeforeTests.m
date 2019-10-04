//
//  AspectsTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"

@interface Parent : NSObject

- (void)parentMethod:(BOOL *)executed;

@end

@implementation Parent

- (void)parentMethod:(BOOL *)executed
{
    if (executed) {
        *executed = YES;
    }
}

@end

@interface Child : NSObject

- (void)childMethod:(BOOL *)executed;

@end

@implementation Child

- (void)childMethod:(BOOL *)executed;
{
    if (executed) {
        *executed = YES;
    }
}

@end

@interface AspectsTests : XCTestCase

@end

@implementation AspectsTests

- (void)testNoHook {
    Child *obj = [[Child alloc] init];
    BOOL executed = NO;
    [obj childMethod:&executed];
    XCTAssert(executed == YES);
}

- (void)testTriggered {
    NSError *error = nil;
    Child *obj = [[Child alloc] init];
    __block BOOL triggered = NO;
    
    [obj aspect_hookSelector:@selector(childMethod:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
    
    XCTAssert(triggered == NO);
    [obj childMethod:NULL];
    XCTAssert(triggered == YES);
}

- (void)testOrder {
    NSError *error = nil;
    Child *obj = [[Child alloc] init];
    __block BOOL executed = NO;
    
    [obj aspect_hookSelector:@selector(childMethod:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        XCTAssert(executed == NO);
    } error:&error];
    XCTAssert(error == nil);
    
    [obj childMethod:&executed];
    XCTAssert(executed == YES);
}



@end
