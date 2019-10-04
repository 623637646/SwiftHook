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
#import "Constant.h"

@interface AllInstanceBeforeTests : XCTestCase

@property (nonatomic, strong) id<AspectToken> token;
@property (nonatomic, assign) BOOL triggered;

@end

@implementation AllInstanceBeforeTests

- (void)setUp {
    NSError *error = nil;
    __weak typeof(self) wself = self;
    self.token = [TestObject aspect_hookSelector:@selector(methodWithExecuted:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        __strong typeof(self) self = wself;
        self.triggered = YES;
        [NSThread sleepForTimeInterval:longTime];
    } error:&error];
    XCTAssert(error == nil);
}

- (void)tearDown {
    BOOL removed = [self.token remove];
    XCTAssert(removed == YES);
    self.triggered = NO;
    self.token = nil;
}

- (void)testTriggered
{
    TestObject *obj = [[TestObject alloc] init];
    XCTAssert(self.triggered == NO);
    [obj methodWithExecuted:NULL];
    XCTAssert(self.triggered == YES);
}

- (void)testOrder
{
    TestObject *obj = [[TestObject alloc] init];
    __block BOOL executed = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(shortTime * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        XCTAssert(self.triggered == YES);
        XCTAssert(executed == NO);
    });
    
    [obj methodWithExecuted:&executed];
    XCTAssert(executed == YES);
}

@end
