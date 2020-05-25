//
//  AspectsErrorTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 26/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveCTestObject.h"
@import Aspects;

// This Testcase should be trigger manually.

@interface AspectsErrorTests : XCTestCase

@end

@implementation AspectsErrorTests

#pragma mark - crashs

/**
 Aspect is not compatible with KVO. Crash on unrecognized selector sent to instance...
 */
- (void)testCrashWithKVOedObject
{
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
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
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    id<AspectToken> token = [object aspect_hookSelector:@selector(setNumber:) withOptions:AspectPositionAfter usingBlock:^(){
    } error:NULL];
    [object addObserver:self forKeyPath:@"number" options:NSKeyValueObservingOptionNew context:NULL];
    [object setNumber:99];
    [token remove];
    [object setNumber:888];
}
/**
 This is similar with testCrashWithKVOedObject. But crash on EXC_BAD_ACCESS.
 */
- (void)testHookDeallocCrashAfterKVO
{
    __block BOOL hooked = NO;
    @autoreleasepool {
        ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
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
    ObjectiveCTestObject *object = [[ObjectiveCTestObject alloc] init];
    __block BOOL hooked = NO;
    [object addObserver:self forKeyPath:@"number" options:NSKeyValueObservingOptionNew context:NULL];
    [object aspect_hookSelector:@selector(noArgsNoReturnFunc) withOptions:AspectPositionAfter usingBlock:^(){
        hooked = YES;
    } error:NULL];
    [object removeObserver:self forKeyPath:@"number"];
    [object noArgsNoReturnFunc];
    XCTAssertTrue(hooked);
}

/**
 A method can only be hooked once per class hierarchy
 */
- (void)testNotSupportHierarchyHook
{
    NSError *error = nil;
    
    [ObjectiveCTestObject aspect_hookSelector:@selector(superFunc) withOptions:AspectPositionAfter usingBlock:^(){
        NSLog(@"");
    } error:&error];
    XCTAssertNil(error);
    
    [ObjectiveCSuperTestObject aspect_hookSelector:@selector(superFunc) withOptions:AspectPositionAfter usingBlock:^(){
        NSLog(@"");
    } error:&error];
    XCTAssertNil(error);
    
    ObjectiveCSuperTestObject *object = [[ObjectiveCSuperTestObject alloc] init];
    [object superFunc];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath: %@", change);
}

@end
