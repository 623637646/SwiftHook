//
//  HookOnceOCTests.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 30/6/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;

@interface MyObject_HookOnceOCTests : NSObject
@property (nonatomic, assign) BOOL run;
@end

@implementation MyObject_HookOnceOCTests

-(void)myMethod
{
    self.run = YES;
}

@end

@interface HookOnceOCTests : XCTestCase

@end

@implementation HookOnceOCTests

- (void)test_specific_object
{
    MyObject_HookOnceOCTests *obj = [[MyObject_HookOnceOCTests alloc] init];
    __block BOOL run = NO;
    NSError *error = nil;
    __block HookToken *token = [obj sh_hookBeforeSelector:@selector(myMethod) error:&error closure:^{
        run = YES;
        [token revert];
    }];
    XCTAssertNil(error);
    
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    [obj myMethod];
    XCTAssertTrue(obj.run);
    XCTAssertTrue(run);
    
    obj.run = NO;
    run = NO;
    XCTAssertFalse(obj.run);
    XCTAssertFalse(run);
    [obj myMethod];
    XCTAssertTrue(obj.run);
    XCTAssertFalse(run);
}

- (void)test_objects
{
    __block BOOL run = NO;
    NSError *error = nil;
    __block HookToken *token = [MyObject_HookOnceOCTests sh_hookBeforeSelector:@selector(myMethod) error:&error closure:^{
        run = YES;
        [token revert];
    }];
    XCTAssertNil(error);
    
    MyObject_HookOnceOCTests *obj1 = [[MyObject_HookOnceOCTests alloc] init];
    XCTAssertFalse(obj1.run);
    XCTAssertFalse(run);
    [obj1 myMethod];
    XCTAssertTrue(obj1.run);
    XCTAssertTrue(run);
    
    run = NO;
    MyObject_HookOnceOCTests *obj2 = [[MyObject_HookOnceOCTests alloc] init];
    XCTAssertFalse(obj2.run);
    XCTAssertFalse(run);
    [obj2 myMethod];
    XCTAssertTrue(obj2.run);
    XCTAssertFalse(run);
}

@end
