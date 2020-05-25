//
//  AspectsTests.m
//  PerformanceTests
//
//  Created by Yanni Wang on 26/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestObject.h"
@import Aspects;

@interface AspectsTests : XCTestCase

@end

@implementation AspectsTests

- (void)testHookBeforeEmptyMethod
{
    TestObject *object = [[TestObject alloc] init];
    __block NSInteger count = 0;
    
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(noArgsNoReturnFunc) withOptions:(AspectPositionBefore) usingBlock:^(id<AspectInfo> params){
        count ++;
    } error:NULL];
    
    // 0.69
    [self measureBlock:^{
        for (NSInteger i = 0; i < measureCount; i++) {
            [object noArgsNoReturnFunc];
        }
    }];
    XCTAssertTrue([token remove]);
    XCTAssertEqual(count, measureCount * 10);
}

- (void)testHookInsteadEmptyMethod
{
    TestObject *object = [[TestObject alloc] init];
    __block NSInteger count = 0;
    
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(noArgsNoReturnFunc) withOptions:(AspectPositionInstead) usingBlock:^(id<AspectInfo> params){
        count ++;
        [[params originalInvocation] invoke];
    } error:NULL];
    
    // 0.7
    [self measureBlock:^{
        for (NSInteger i = 0; i < measureCount; i++) {
            [object noArgsNoReturnFunc];
        }
    }];
    XCTAssertTrue([token remove]);
    XCTAssertEqual(count, measureCount * 10);
}

- (void)testSingleHookAfterEmptyMethod
{
    TestObject *object = [[TestObject alloc] init];
    __block NSInteger count = 0;
    
    id<AspectToken> token = [object aspect_hookSelector:@selector(noArgsNoReturnFunc) withOptions:(AspectPositionBefore) usingBlock:^(id<AspectInfo> params){
        count ++;
    } error:NULL];
    
    // 0.66
    [self measureBlock:^{
        for (NSInteger i = 0; i < measureCount; i++) {
            [object noArgsNoReturnFunc];
        }
    }];
    XCTAssertTrue([token remove]);
    XCTAssertEqual(count, measureCount * 10);
}

- (void)testSingleHookInsteadEmptyMethod
{
    TestObject *object = [[TestObject alloc] init];
    __block NSInteger count = 0;
    
    id<AspectToken> token = [object aspect_hookSelector:@selector(noArgsNoReturnFunc) withOptions:(AspectPositionInstead) usingBlock:^(id<AspectInfo> params){
        count ++;
        [[params originalInvocation] invoke];
    } error:NULL];
    
    // 0.67
    [self measureBlock:^{
        for (NSInteger i = 0; i < measureCount; i++) {
            [object noArgsNoReturnFunc];
        }
    }];
    XCTAssertTrue([token remove]);
    XCTAssertEqual(count, measureCount * 10);
}

@end
