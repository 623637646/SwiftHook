//
//  AspectsTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestObject.h"
#import <objc/runtime.h>
@import Aspects;

@interface AspectsTests : XCTestCase

@end

@implementation AspectsTests

#pragma mark - crashs

/**
 Aspect is not compatible with KVO. Crash on unrecognized selector sent to instance...
 */
- (void)testCrashWithKVOObject
{
    TestObject *object = [[TestObject alloc] init];
    [object addObserver:self forKeyPath:@"number" options:NSKeyValueObservingOptionNew context:NULL];
    [object aspect_hookSelector:@selector(setNumber:) withOptions:AspectPositionAfter usingBlock:^(){
    } error:NULL];
    [object setNumber:99];
}

/**
 Aspect is not compatible with KVO. Hook aspects first, Then KVO, Then cancel aspects hook. call the method. crash.
 */
- (void)testCrashOnCancellationAspectsAfterKVO
{
    TestObject *object = [[TestObject alloc] init];
    id<AspectToken> token = [object aspect_hookSelector:@selector(setNumber:) withOptions:AspectPositionAfter usingBlock:^(){
    } error:NULL];
    [object addObserver:self forKeyPath:@"number" options:NSKeyValueObservingOptionNew context:NULL];
    [object setNumber:99];
    [token remove];
    [object setNumber:888];
}
/**
 This is similar with testCrashWithKVOObject. But crash on EXC_BAD_ACCESS.
 */
- (void)testHookDeallocCrashAfterKVO
{
    __block BOOL hooked = NO;
    @autoreleasepool {
        TestObject *object = [[TestObject alloc] init];
        [object addObserver:self forKeyPath:@"number" options:NSKeyValueObservingOptionNew context:NULL];
        [object aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^(){
            hooked = YES;
        } error:NULL];
    }
    XCTAssertTrue(hooked);
}
/**
 Crash on EXC_BAD_ACCESS
 */
- (void)testCrashWithString
{
    // normal (string's class is __NSCFConstantString)
    [[[NSString alloc] initWithFormat:@""] aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];

    // normal (string's class is __NSCFConstantString)
    [[[NSString alloc] init] aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];
    
    // crash (string's class is NSTaggedPointerString)
    [[[NSString alloc] initWithFormat:@"11"] aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];
}

#pragma mark - Unexpected

- (void)testHookFailureAfterKVOCancel
{
    TestObject *object = [[TestObject alloc] init];
    __block BOOL hooked = NO;
    [object addObserver:self forKeyPath:@"number" options:NSKeyValueObservingOptionNew context:NULL];
    [object aspect_hookSelector:@selector(noArgsNoReturnFunc) withOptions:AspectPositionAfter usingBlock:^(){
        hooked = YES;
    } error:NULL];
    [object removeObserver:self forKeyPath:@"number"];
    [object noArgsNoReturnFunc];
    XCTAssertTrue(hooked);
}

- (void)testNotSupportHierarchyHook
{
    NSError *error = nil;
    
    [TestObject aspect_hookSelector:@selector(superFunc) withOptions:AspectPositionAfter usingBlock:^(){
        NSLog(@"");
    } error:&error];
    XCTAssertNil(error);
    
    [SuperTestObject aspect_hookSelector:@selector(superFunc) withOptions:AspectPositionAfter usingBlock:^(){
        NSLog(@"");
    } error:&error];
    XCTAssertNil(error);
    
    SuperTestObject *object = [[SuperTestObject alloc] init];
    [object superFunc];
}

#pragma mark - Normal

- (void)testClassMethod
{
    NSError *error = nil;
    [object_getClass(TestObject.class) aspect_hookSelector:@selector(classMethod) withOptions:AspectPositionAfter usingBlock:^(){
        NSLog(@"");
    } error:&error];
    XCTAssertNil(error);
    
    [TestObject classMethod];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath: %@", change);
}

@end
