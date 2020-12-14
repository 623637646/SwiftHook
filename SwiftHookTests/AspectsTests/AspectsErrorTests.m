//
//  AspectsErrorTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 26/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveCTestObject.h"
#import <objc/runtime.h>
@import Aspects;

// This Testcase should be trigger manually.

@interface AspectsErrorTests : XCTestCase

@end

@implementation AspectsErrorTests

#pragma mark - crashs

/**
 Crash: -[ObjectiveCTestObject aspects__setNumber:]: unrecognized selector sent to instance 0x7ffe53e20da0
 Reason:
 1. After KVO. The object's class will be set to a dynamic class named NSKVONotifying_ObjectiveCTestObject. This class override the setNumber: method.
 2. Aspect hook the same method. If the [object class] is different with object_getClass(object). Will hook WITHOUT creating a dynamic class (See Aspects.m:357).
 3. Aspect add new method named aspects__setNumber. Swizzle aspects__setNumber and original setNumber. (And some other swizzling like forwardInvocation:)
 Now the logic is:
 [object setNumber:99] -> Aspects block -> [object aspects__setNumber:99] -> KVO's logic -> call original with selector(_cmd) -> The final IMP of ObjectiveCTestObject
 This bug already has a Pull Request: https://github.com/steipete/Aspects/pull/115
 The article (Chinese): https://juejin.im/post/5ddf9025e51d456b345adf26
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
 Crash: Assertion failure in void aspect_cleanupHookedClassAndSelector(NSObject *__strong, SEL)()
 Reason:
 1. Hook with Aspects. The object's class (isa) is changed to ObjectiveCTestObject_Aspects_
 2. After KVO. The isa is changed to NSKVONotifying_ObjectiveCTestObject_Aspects_
 3. Remove Aspects. Aspects wants to change the isa from ObjectiveCTestObject_Aspects_ to ObjectiveCTestObject. But actually the isa is changed from NSKVONotifying_ObjectiveCTestObject_Aspects_ to NSKVONotifying_ObjectiveCTestObject
 But there is no class named NSKVONotifying_ObjectiveCTestObject. So crash.
 The article (Chinese): https://juejin.im/post/5ddf9025e51d456b345adf26
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
 Crash on EXC_BAD_ACCESS.
 Maybe the reason is:
 NSInvocation's selector is "aspects__dealloc". This is not compatible with KVO.
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
 This crash happens on SwiftHook too!!!
 This is related to: https://stackoverflow.com/a/62068020/9315497
 Actually "NSTaggedPointerString" is not objects. "__NSCFString" is objects. Sometimes "__NSCFConstantString" is object sometimes not.
 */
- (void)testCrashWithString
{
    // normal (string's class is __NSCFString)
    [[[NSString alloc] initWithFormat:@"123312312312312312312312312312131231"] aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];
    
    // normal (string's class is __NSCFConstantString)
    [[[NSString alloc] initWithFormat:@""] aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];

    // crash (string's class is __NSCFConstantString)
    [@"" aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];

    // crash (string's class is NSTaggedPointerString)
    [[[NSString alloc] initWithFormat:@"11"] aspect_hookSelector:NSSelectorFromString(@"length") withOptions:AspectPositionBefore usingBlock:^(){
    } error:NULL];
}

/**
 Crash: -[ObjectiveCTestObject setNumber:]: unrecognized selector sent to instance 0x7fc5c9824cb0
 Reason: In Aspects.m:434
 1. After hooking "object_getClass(ObjectiveCTestObject.class) classNoArgsNoReturnFunc". swizzledClasses contained "ObjectiveCTestObject" (It's a NSString set).
 2. When hook with "ObjectiveCTestObject setNumber:", Will skip "aspect_swizzleForwardInvocation" because "ObjectiveCTestObject" already hooked (This is wrong. Actually last class is meta-class, this class is normal class. They have the same class name).
 3. It will crash without did "aspect_swizzleForwardInvocation".
 */
- (void)testClassMethodUnknownbeHavior
{
    id<AspectToken> token = [object_getClass(ObjectiveCTestObject.class) aspect_hookSelector:@selector(classNoArgsNoReturnFunc) withOptions:AspectPositionBefore usingBlock:^(){
        NSLog(@"");
    } error:NULL];
    [ObjectiveCTestObject classNoArgsNoReturnFunc];
    NSLog(@"%@", token);
//    [token remove]; // Remove hook can avoid crash.
    
    [ObjectiveCTestObject aspect_hookSelector:@selector(setNumber:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        NSLog(@"");
    } error:NULL];
    [[ObjectiveCTestObject alloc] init].number = 9;
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

- (void)testCMDIsWrong
{
    NSError *error = nil;
    [self aspect_hookSelector:@selector(checkCMD) withOptions:AspectPositionAfter usingBlock:^(){
    } error:&error];
    XCTAssertNil(error);
    [self checkCMD];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath: %@", change);
}

#pragma mark - others
- (void)checkCMD
{
    XCTAssertEqualObjects(NSStringFromSelector(_cmd), @"checkCMD");
}

@end
