//
//  AspectsInsteadHookTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestObject.h"
#import <objc/runtime.h>
@import Aspects;

@interface AspectsInsteadHookTests : XCTestCase

@end

@implementation AspectsInsteadHookTests

- (void)testModifyIntReture {
    [self aspect_hookSelector:@selector(getInteger) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        NSInvocation *invocation = info.originalInvocation;
        NSInteger integer;
        [invocation invoke];
        [invocation getReturnValue:&integer];
        XCTAssertEqual(integer, 999);
        integer = 333;
        [invocation setReturnValue:&integer];
    } error:NULL];
    NSInteger integer = [self getInteger];
    XCTAssertEqual(integer, 333);
}

- (void)testModifyObjectReture {
    [self aspect_hookSelector:@selector(getTestObject) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
        // NSInvocation is not supported on Swfit!
        NSInvocation *invocation = info.originalInvocation;
        // __unsafe_unretained is necessary. otherwise will on EXC_BAD_ACCESS
        __unsafe_unretained TestObject *testObject;
        [invocation invoke];
        [invocation getReturnValue:&testObject];
        XCTAssertEqual(testObject.number, 999);
        
        TestObject *newTestObject = [[TestObject alloc] init];
        newTestObject.number = 333;
        // objc_setAssociatedObject is necessary. otherwise will on EXC_BAD_ACCESS
        objc_setAssociatedObject(invocation, _cmd, newTestObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [invocation setReturnValue:&newTestObject];
    } error:NULL];
    TestObject *testObject = [self getTestObject];
    XCTAssertEqual(testObject.number, 333);
}

#pragma mark - utilities

- (TestObject *)getTestObject
{
    TestObject *testObject = [[TestObject alloc] init];
    testObject.number = 999;
    return testObject;
}

- (NSInteger)getInteger
{
    return 999;
}

@end
