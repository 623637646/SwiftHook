//
//  HookClassMethodsOCTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;

BOOL run_HookClassMethodsOCTests = NO;
HookToken *token_HookClassMethodsOCTests = nil;

@interface MyObject_HookClassMethodsOCTests : NSObject
@end

@implementation MyObject_HookClassMethodsOCTests

+ (void)myMethod
{
    run_HookClassMethodsOCTests = YES;
}

+ (NSInteger)myMethodWithNumber:(NSInteger)number url:(NSURL *)URL
{
    run_HookClassMethodsOCTests = YES;
    return number * 2;
}

@end

@interface HookClassMethodsOCTests : XCTestCase

@end

@implementation HookClassMethodsOCTests

- (void)setUp
{
    [super setUp];
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertNil(token_HookClassMethodsOCTests);
}

- (void)tearDown
{
    [super tearDown];
    run_HookClassMethodsOCTests = NO;
    [token_HookClassMethodsOCTests revert];
    token_HookClassMethodsOCTests = nil;
}

// MARK: - empty closure

// before

- (void)test_before
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodBeforeSelector:@selector(myMethod) error:&error closure:^{
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
    }];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    [MyObject_HookClassMethodsOCTests myMethod];
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}

// after

- (void)test_after
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodAfterSelector:@selector(myMethod) error:&error closure:^{
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
    }];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    [MyObject_HookClassMethodsOCTests myMethod];
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}

// MARK: - self and selector closure

// before

- (void)test_before_obj_sel
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodBeforeSelector:@selector(myMethod) error:&error closureObjSel:^(Class  _Nonnull __unsafe_unretained class, SEL _Nonnull sel) {
        XCTAssertTrue(MyObject_HookClassMethodsOCTests.class == class);
        XCTAssertEqual(sel, @selector(myMethod));
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
     }];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    [MyObject_HookClassMethodsOCTests myMethod];
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}

// after

- (void)test_after_obj_sel
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodAfterSelector:@selector(myMethod) error:&error closureObjSel:^(Class  _Nonnull __unsafe_unretained class, SEL _Nonnull sel) {
        XCTAssertTrue(MyObject_HookClassMethodsOCTests.class == class);
        XCTAssertEqual(sel, @selector(myMethod));
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
     }];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    [MyObject_HookClassMethodsOCTests myMethod];
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}

// MARK: - custom closure

// before

- (void)test_before_custom
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodBeforeSelector:@selector(myMethodWithNumber:url:) closure:^(NSObject *  _Nonnull __unsafe_unretained class, SEL _Nonnull sel) {
        XCTAssertTrue(MyObject_HookClassMethodsOCTests.class == (Class)class);
        XCTAssertEqual(sel, @selector(myMethodWithNumber:url:));
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
    } error:&error];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    NSInteger result = [MyObject_HookClassMethodsOCTests myMethodWithNumber:77 url:[NSURL URLWithString:@"https://google.com"]];
    XCTAssertEqual(result, 154);
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}

// after

- (void)test_after_custom
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodAfterSelector:@selector(myMethodWithNumber:url:) closure:^(NSObject *  _Nonnull __unsafe_unretained class, SEL _Nonnull sel, NSInteger number, NSURL *url) {
        XCTAssertTrue(MyObject_HookClassMethodsOCTests.class == (Class)class);
        XCTAssertEqual(sel, @selector(myMethodWithNumber:url:));
        XCTAssertEqual(number, 77);
        XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://google.com"]);
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
    } error:&error];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    NSInteger result = [MyObject_HookClassMethodsOCTests myMethodWithNumber:77 url:[NSURL URLWithString:@"https://google.com"]];
    XCTAssertEqual(result, 154);
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}

// instead

- (void)test_instead_custom
{
    __block BOOL run = NO;
    XCTAssertFalse(run);
    NSError *error = nil;
    token_HookClassMethodsOCTests = [MyObject_HookClassMethodsOCTests sh_hookClassMethodInsteadWithSelector:@selector(myMethodWithNumber:url:) closure:^NSInteger (NSInteger(^original)(NSObject *  _Nonnull __unsafe_unretained class, SEL _Nonnull sel, NSInteger number, NSURL *url), NSObject *  _Nonnull __unsafe_unretained class, SEL _Nonnull sel, NSInteger number, NSURL *url) {
        XCTAssertTrue(MyObject_HookClassMethodsOCTests.class == (Class)class);
        XCTAssertEqual(sel, @selector(myMethodWithNumber:url:));
        XCTAssertEqual(number, 77);
        XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://google.com"]);
        XCTAssertFalse(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        NSInteger result = original(class, sel, 11, url);
        XCTAssertEqual(result, 22);
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(run_HookClassMethodsOCTests);
        XCTAssertTrue(run);
        return 999;
    } error:&error];
    XCTAssertNil(error);
    XCTAssertFalse(run_HookClassMethodsOCTests);
    XCTAssertFalse(run);
    NSInteger result = [MyObject_HookClassMethodsOCTests myMethodWithNumber:77 url:[NSURL URLWithString:@"https://google.com"]];
    XCTAssertEqual(result, 999);
    XCTAssertTrue(run_HookClassMethodsOCTests);
    XCTAssertTrue(run);
}


@end
