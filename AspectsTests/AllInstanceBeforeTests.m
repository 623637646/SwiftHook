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

@property (nonatomic, strong) id<AspectToken> token;
@property (nonatomic, assign) BOOL triggered;
@property (nonatomic, assign) BOOL executed;

@end

@implementation AllInstanceBeforeTests

- (void)setUp
{
    NSError *error = nil;
    __weak typeof(self) wself = self;
    self.token = [TestObject aspect_hookSelector:@selector(methodWithExecutedBlock:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        __strong typeof(self) self = wself;
        XCTAssert(self.triggered == NO);
        XCTAssert(self.executed == NO);
        self.triggered = YES;
    } error:&error];
    XCTAssert(error == nil);
}

- (void)tearDown
{
    BOOL removed = [self.token remove];
    XCTAssert(removed == YES);
    self.triggered = NO;
    self.executed = NO;
    self.token = nil;
}

- (void)testTriggered
{
    TestObject *obj = [[TestObject alloc] init];
    XCTAssert(self.triggered == NO);
    [obj methodWithExecutedBlock:nil];
    XCTAssert(self.triggered == YES);
}

- (void)testOrder
{
    TestObject *obj = [[TestObject alloc] init];
    __weak typeof(self) wself = self;
    [obj methodWithExecutedBlock:^{
        __strong typeof(self) self = wself;
        XCTAssert(self.triggered == YES);
        XCTAssert(self.executed == NO);
        self.executed = YES;
    }];
    XCTAssert(self.executed == YES);
}

@end
