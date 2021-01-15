//
//  KVOWrapperOCTests.m
//  SwiftHookTests
//
//  Created by Wang Ya on 1/15/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;

@interface MyObject1 : NSObject{
    NSInteger _number;
}
@end

@implementation MyObject1
- (NSInteger)number
{
    return _number;
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
}
@end

@interface MyObject2 : NSObject{
    NSInteger _number;
}
@end

@implementation MyObject2
- (NSInteger)Number
{
    return _number;
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
}
@end

@interface MyObject3 : NSObject{
    NSInteger _number;
}
@end

@implementation MyObject3
- (NSInteger)isNumber
{
    return _number;
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
}
@end

@interface MyObject4 : NSObject{
    NSInteger _number;
}
@end

@implementation MyObject4
- (NSInteger)isNumber
{
    return _number;
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
}
@end


@interface KVOWrapperOCTests : XCTestCase

@property (nonatomic, strong) NSMutableArray<NSNumber *> *order;

@end

@implementation KVOWrapperOCTests

- (void)setUp {
    self.order = [[NSMutableArray<NSNumber *> alloc] init];
}

- (void)test_no_property {
    NSString *name = @"number";
    MyObject1 *object = [[MyObject1 alloc] init];
    
    NSError *error = nil;
    [object sh_hookInsteadWithSelector:@selector(setNumber:) closure:^(void(^original)(MyObject1 *object, SEL selector, NSInteger number), MyObject1 *object, SEL selector, NSInteger number){
        [self.order addObject:@1];
        original(object, selector, number);
        [self.order addObject:@3];
    } error:&error];
    XCTAssertNil(error);
    [object addObserver:self forKeyPath:name options:NSKeyValueObservingOptionNew context:NULL];

    object.number = 9;
    NSArray *expectation = @[@1, @2, @3];
    XCTAssertEqualObjects(self.order, expectation);
    [object removeObserver:self forKeyPath:name];
}

- (void)test_no_property_uppercase {
    NSString *name = @"Number";
    MyObject2 *object = [[MyObject2 alloc] init];
    
    NSError *error = nil;
    [object sh_hookInsteadWithSelector:@selector(setNumber:) closure:^(void(^original)(MyObject2 *object, SEL selector, NSInteger number), MyObject2 *object, SEL selector, NSInteger number){
        [self.order addObject:@1];
        original(object, selector, number);
        [self.order addObject:@3];
    } error:&error];
    XCTAssertNil(error);
    [object addObserver:self forKeyPath:name options:NSKeyValueObservingOptionNew context:NULL];

    object.number = 9;
    NSArray *expectation = @[@1, @2, @3];
    XCTAssertEqualObjects(self.order, expectation);
    [object removeObserver:self forKeyPath:name];
}

- (void)test_no_property_isNumber {
    NSString *name = @"number";
    MyObject3 *object = [[MyObject3 alloc] init];
    
    NSError *error = nil;
    [object sh_hookInsteadWithSelector:@selector(setNumber:) closure:^(void(^original)(MyObject3 *object, SEL selector, NSInteger number), MyObject3 *object, SEL selector, NSInteger number){
        [self.order addObject:@1];
        original(object, selector, number);
        [self.order addObject:@3];
    } error:&error];
    XCTAssertNil(error);
    [object addObserver:self forKeyPath:name options:NSKeyValueObservingOptionNew context:NULL];

    object.number = 9;
    NSArray *expectation = @[@1, @2, @3];
    XCTAssertEqualObjects(self.order, expectation);
    [object removeObserver:self forKeyPath:name];
}

- (void)test_no_property_isNumber_uppercase {
    NSString *name = @"Number";
    MyObject4 *object = [[MyObject4 alloc] init];
    
    NSError *error = nil;
    [object sh_hookInsteadWithSelector:@selector(setNumber:) closure:^(void(^original)(MyObject4 *object, SEL selector, NSInteger number), MyObject4 *object, SEL selector, NSInteger number){
        [self.order addObject:@1];
        original(object, selector, number);
        [self.order addObject:@3];
    } error:&error];
    XCTAssertNil(error);
    [object addObserver:self forKeyPath:name options:NSKeyValueObservingOptionNew context:NULL];

    object.number = 9;
    NSArray *expectation = @[@1, @2, @3];
    XCTAssertEqualObjects(self.order, expectation);
    [object removeObserver:self forKeyPath:name];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == NULL) {
        [self.order addObject:@2];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
