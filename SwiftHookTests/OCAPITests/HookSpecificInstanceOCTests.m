//
//  HookSpecificInstanceOCTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 28/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;

BOOL isReleased_HookSpecificInstanceOCTests = NO;

@interface MyObject_HookSpecificInstanceOCTests : NSObject
@property (nonatomic, assign) BOOL run;
@property (nonatomic, copy) NSString *name;
@end

@implementation MyObject_HookSpecificInstanceOCTests

-(void)myMethod
{
    self.run = YES;
}

-(NSInteger)myMethodWithNumber:(NSInteger)number url:(NSURL *)URL
{
    self.run = YES;
    return number * 2;
}

-(void)dealloc
{
    isReleased_HookSpecificInstanceOCTests = YES;
}

@end

@interface HookSpecificInstanceOCTests : XCTestCase

@end

@implementation HookSpecificInstanceOCTests

- (void)setUp
{
    [super setUp];
    XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
}

- (void)tearDown
{
    [super tearDown];
    isReleased_HookSpecificInstanceOCTests = NO;
}

// MARK: - empty closure

// before

- (void)test_before
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookBeforeSelector:@selector(myMethod) error:&error closure:^{
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertFalse(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertFalse(obj.run);
        XCTAssertTrue(run);
    }];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    [obj myMethod];
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// after

- (void)test_after
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookAfterSelector:@selector(myMethod) error:&error closure:^{
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertTrue(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(obj.run);
        XCTAssertTrue(run);
    }];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    [obj myMethod];
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// MARK: - self and selector closure

// before

- (void)test_before_obj_sel
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookBeforeSelector:@selector(myMethod) error:&error closureObjSel:^(NSObject * _Nonnull object, SEL _Nonnull sel) {
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertTrue(obj == object);
        XCTAssertEqual(sel, @selector(myMethod));
        XCTAssertFalse(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertFalse(obj.run);
        XCTAssertTrue(run);
     }];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    [obj myMethod];
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// after

- (void)test_after_obj_sel
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookAfterSelector:@selector(myMethod) error:&error closureObjSel:^(NSObject * _Nonnull object, SEL _Nonnull sel) {
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertTrue(obj == object);
        XCTAssertEqual(sel, @selector(myMethod));
        XCTAssertTrue(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(obj.run);
        XCTAssertTrue(run);
     }];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    [obj myMethod];
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// MARK: - custom closure

// before

- (void)test_before_custom
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookBeforeSelector:@selector(myMethodWithNumber:url:) closure:^(NSObject * _Nonnull object, SEL _Nonnull sel) {
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertTrue(obj == object);
        XCTAssertEqual(sel, @selector(myMethodWithNumber:url:));
        XCTAssertFalse(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertFalse(obj.run);
        XCTAssertTrue(run);
    } error:&error];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSInteger result = [obj myMethodWithNumber:77 url:[NSURL URLWithString:@"https://google.com"]];
    XCTAssertEqual(result, 154);
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// after

- (void)test_after_custom
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookAfterSelector:@selector(myMethodWithNumber:url:) closure:^(NSObject * _Nonnull object, SEL _Nonnull sel, NSInteger number, NSURL *url) {
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertTrue(obj == object);
        XCTAssertEqual(sel, @selector(myMethodWithNumber:url:));
        XCTAssertEqual(number, 77);
        XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://google.com"]);
        XCTAssertTrue(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(obj.run);
        XCTAssertTrue(run);
    } error:&error];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSInteger result = [obj myMethodWithNumber:77 url:[NSURL URLWithString:@"https://google.com"]];
    XCTAssertEqual(result, 154);
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// instead

- (void)test_instead_custom
{
    MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
    __block BOOL run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSError *error = nil;
    __weak typeof(obj) wobj = obj;
    [obj sh_hookInsteadWithSelector:@selector(myMethodWithNumber:url:) closure:^NSInteger (NSInteger(^original)(NSObject * _Nonnull object, SEL _Nonnull sel, NSInteger number, NSURL *url), NSObject * _Nonnull object, SEL _Nonnull sel, NSInteger number, NSURL *url) {
        __strong typeof(obj) obj = wobj;
        XCTAssertNotNil(obj);
        XCTAssertTrue(obj == object);
        XCTAssertEqual(sel, @selector(myMethodWithNumber:url:));
        XCTAssertEqual(number, 77);
        XCTAssertEqualObjects(url, [NSURL URLWithString:@"https://google.com"]);
        XCTAssertFalse(obj.run);
        XCTAssertFalse(run);
        NSInteger result = original(object, sel, 11, url);
        XCTAssertEqual(result, 22);
        XCTAssertTrue(obj.run);
        XCTAssertFalse(run);
        run = YES;
        XCTAssertTrue(obj.run);
        XCTAssertTrue(run);
        return 999;
    } error:&error];
    XCTAssertNil(error);
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    NSInteger result = [obj myMethodWithNumber:77 url:[NSURL URLWithString:@"https://google.com"]];
    XCTAssertEqual(result, 999);
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
}

// MARK: before deinit

- (void)test_before_deinit
{
    __weak MyObject_HookSpecificInstanceOCTests *reference = nil;
    __block BOOL run = NO;
    
    @autoreleasepool {
        XCTAssertNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
        reference = obj;
        XCTAssertNotNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        NSError *error = nil;
        [obj sh_hookDeallocBeforeAndReturnError:&error closure:^{
            XCTAssertNil(reference);
            XCTAssertEqual(run, NO);
            run = YES;
            XCTAssertNil(reference);
            XCTAssertEqual(run, YES);
            XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        }];
        XCTAssertNil(error);
    }
    XCTAssertNil(reference);
    XCTAssertEqual(run, YES);
    XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
}

- (void)test_before_deinit_obj
{
    __weak MyObject_HookSpecificInstanceOCTests *reference = nil;
    __block BOOL run = NO;
    
    @autoreleasepool {
        XCTAssertNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
        obj.name = @"kkk";
        reference = obj;
        XCTAssertNotNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        NSError *error = nil;
        [obj sh_hookDeallocBeforeAndReturnError:&error closureObj:^(NSObject * _Nonnull obj) {
            XCTAssertNil(reference);
            XCTAssertEqual(run, NO);
            XCTAssertEqualObjects(((MyObject_HookSpecificInstanceOCTests *)obj).name, @"kkk");
            run = YES;
            XCTAssertNil(reference);
            XCTAssertEqual(run, YES);
            XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        }];
        XCTAssertNil(error);
    }
    XCTAssertNil(reference);
    XCTAssertEqual(run, YES);
    XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
}

// MARK: after deinit

- (void)test_after_deinit
{
    __weak MyObject_HookSpecificInstanceOCTests *reference = nil;
    __block BOOL run = NO;
    
    @autoreleasepool {
        XCTAssertNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
        reference = obj;
        XCTAssertNotNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        NSError *error = nil;
        [obj sh_hookDeallocAfterAndReturnError:&error closure:^{
            XCTAssertNil(reference);
            XCTAssertEqual(run, NO);
            run = YES;
            XCTAssertNil(reference);
            XCTAssertEqual(run, YES);
            XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
        }];
        XCTAssertNil(error);
    }
    XCTAssertNil(reference);
    XCTAssertEqual(run, YES);
    XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
}

- (void)test_after_deinit_tail
{
    __weak MyObject_HookSpecificInstanceOCTests *reference = nil;
    __block BOOL run = NO;
    
    @autoreleasepool {
        XCTAssertNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
        reference = obj;
        XCTAssertNotNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        [obj sh_hookDeallocAfterByTailWithClosure:^{
            XCTAssertNil(reference);
            XCTAssertEqual(run, NO);
            run = YES;
            XCTAssertNil(reference);
            XCTAssertEqual(run, YES);
            XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
        }];
    }
    XCTAssertNil(reference);
    XCTAssertEqual(run, YES);
    XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
}

// MARK: replace deinit

- (void)test_install_deinit
{
    __weak MyObject_HookSpecificInstanceOCTests *reference = nil;
    __block BOOL run = NO;
    
    @autoreleasepool {
        XCTAssertNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        MyObject_HookSpecificInstanceOCTests *obj = [[MyObject_HookSpecificInstanceOCTests alloc] init];
        reference = obj;
        XCTAssertNotNil(reference);
        XCTAssertEqual(run, NO);
        XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
        NSError *error = nil;
        [obj sh_hookDeallocInsteadAndReturnError:&error closure:^(void (^ _Nonnull original)(void)) {
            XCTAssertNil(reference);
            XCTAssertEqual(run, NO);
            XCTAssertFalse(isReleased_HookSpecificInstanceOCTests);
            original();
            run = YES;
            XCTAssertNil(reference);
            XCTAssertEqual(run, YES);
            XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
        }];
        XCTAssertNil(error);
    }
    XCTAssertNil(reference);
    XCTAssertEqual(run, YES);
    XCTAssertTrue(isReleased_HookSpecificInstanceOCTests);
}

@end
