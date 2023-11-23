//
//  SpecialClassTests.m
//  SwiftHookTests
//
//  Created by Wang Ya on 1/22/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SwiftHook;
#import "SwiftHookTests-Swift.h"
#import <objc/runtime.h>

@interface MyURL43212231212 : NSURL
@end
@implementation MyURL43212231212
@end

@interface SpecialClassTests : XCTestCase

@end

@implementation SpecialClassTests

// MARK: NSString

- (void)test_NSString {
    [self utilities_test_NSString_obj1:@"123" obj2:@"1234" className:@"__NSCFConstantString"];
    [self utilities_test_NSString_obj1:[[NSString alloc] initWithFormat:@"1233243242423432432432423432424242423324234"]
                                  obj2:[[NSString alloc] initWithFormat:@"12332432424234324324324234324242424233242342"]
                             className:@"__NSCFString"];
    
    [self utilities_test_NSString_obj1:[[NSMutableString alloc] initWithFormat:@"1233243242423432432432423432424242423324234"]
                                  obj2:[[NSMutableString alloc] initWithFormat:@"4567"]
                             className:@"__NSCFString"];
}

- (void)test_NSTaggedPointerString {
    NSString *obj = [[NSString alloc] initWithFormat:@"123"];
    XCTAssertEqualObjects(NSStringFromClass([obj class]), @"NSTaggedPointerString");
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj)), @"NSTaggedPointerString");
    Class originalClass = object_getClass(obj);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(length));
    XCTAssertFalse(originalIMP == NULL);
    
    
    [obj addObserver:self forKeyPath:@"aaa" options:NSKeyValueObservingOptionNew context:NULL];
    XCTAssertEqualObjects(NSStringFromClass([obj class]), @"NSTaggedPointerString");
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj)), @"NSTaggedPointerString");
    XCTAssertEqual(obj.length, 3);
    
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];
    NSError *error = nil;
    OCToken *token = [obj sh_hookAfterSelector:@selector(length) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 10);
    XCTAssertEqualObjects(error.localizedDescription, @"Unsupport to hook instance of NSTaggedPointerString.");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(length));
    XCTAssertEqual(originalIMP, newIMP);
    
    NSUInteger length = [obj length];
    XCTAssertEqual(length, 3);
    XCTAssertEqualObjects(expectation, @[]);
    [expectation removeAllObjects];
    
    NSString *obj2 = [[NSString alloc] initWithFormat:@"4567"];
    NSUInteger length2 = [obj2 length];
    XCTAssertEqual(length2, 4);
    XCTAssertEqualObjects(expectation, @[]);
    
    [token cancelHook];
    NSUInteger length3 = [obj length];
    XCTAssertEqual(length3, 3);
    XCTAssertEqualObjects(expectation, @[]);
}

- (void)utilities_test_NSString_obj1:(NSString *)obj1 obj2:(NSString *)obj2 className:(NSString *)className {
    NSUInteger length1 = [obj1 length];
    NSUInteger length2 = [obj2 length];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");
    
    [obj1 addObserver:self forKeyPath:@"aaa" options:NSKeyValueObservingOptionNew context:NULL];
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqual(obj1.length, length1);

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(length) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 11);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    XCTAssertEqual([obj1 length], length1);
    XCTAssertEqualObjects(expectation, @[]);
    
    [expectation removeAllObjects];
    XCTAssertEqual([obj2 length], length2);
    XCTAssertEqualObjects(expectation, obj1 == obj2 ? @[@1] : @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    XCTAssertEqual([obj1 length], length1);
    XCTAssertEqualObjects(expectation, @[]);

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
}

- (void)test_all_instances_NSString{
    [self utilities_test_all_instances_NSString:@"__NSCFConstantString" obj:@"123"];
    [self utilities_test_all_instances_NSString:@"NSTaggedPointerString" obj:[[NSString alloc] initWithFormat:@"123"]];
    [self utilities_test_all_instances_NSString:@"__NSCFString" obj:[[NSString alloc] initWithFormat:@"1233243242423432432432423432424242423324234"]];
    [self utilities_test_all_instances_NSString:@"__NSCFString" obj:[[NSMutableString alloc] initWithFormat:@"1233243242423432432432423432424242423324234"]];
}

- (void)utilities_test_all_instances_NSString:(NSString *)className obj:(NSString *)obj {
    NSUInteger length = [obj length];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(length));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(length) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(length));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj length], length);
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj length], length);
    XCTAssertEqual(expectation, 0);
}

// MARK: NSArray

- (void)test_NSArray {
    [self utilities_test_NSArray_obj1:@[] obj2:@[] className:@"__NSArray0"];
    [self utilities_test_NSArray_obj1:@[@1] obj2:@[@2] className:@"__NSSingleObjectArrayI"];
    [self utilities_test_NSArray_obj1:@[@1, @2] obj2:@[@2, @3, @4] className:@"__NSArrayI"];
    [self utilities_test_NSArray_obj1:[@[@1, @2] mutableCopy] obj2:[@[@2, @3, @4] mutableCopy] className:@"__NSArrayM"];
}

- (void)utilities_test_NSArray_obj1:(NSArray *)obj1 obj2:(NSArray *)obj2 className:(NSString *)className {
    NSUInteger count1 = [obj1 count];
    NSUInteger count2 = [obj2 count];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];
    
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(count) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 11);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);
    
    [expectation removeAllObjects];
    XCTAssertEqual([obj2 count], count2);
    XCTAssertEqualObjects(expectation, @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
}

- (void)test_all_instances_NSArray{
    [self utilities_test_all_instances_NSArray:@"__NSArray0" obj:@[]];
    [self utilities_test_all_instances_NSArray:@"__NSSingleObjectArrayI" obj:@[@2]];
    [self utilities_test_all_instances_NSArray:@"__NSArrayI" obj:@[@1, @2]];
    [self utilities_test_all_instances_NSArray:@"__NSArrayM" obj:[@[@2, @3, @4] mutableCopy]];
}

- (void)utilities_test_all_instances_NSArray:(NSString *)className obj:(NSArray *)obj {
    NSUInteger count = [obj count];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(count) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 0);
}

// MARK: NSDictionary

- (void)test_NSDictionary {
    [self utilities_test_NSDictionary_obj1:@{} obj2:@{} className:@"__NSDictionary0"];
    [self utilities_test_NSDictionary_obj1:@{@"key": @1} obj2:@{@"key": @2} className:@"__NSSingleEntryDictionaryI"];
    [self utilities_test_NSDictionary_obj1:@{@"key1": @1, @"key2": @2} obj2:@{@"key1": @1, @"key2": @2, @"key3": @3} className:@"__NSDictionaryI"];
    [self utilities_test_NSDictionary_obj1:[@{@"key1": @1, @"key2": @2} mutableCopy] obj2:[@{@"key1": @1, @"key2": @2, @"key3": @3} mutableCopy] className:@"__NSDictionaryM"];
}

- (void)utilities_test_NSDictionary_obj1:(NSDictionary *)obj1 obj2:(NSDictionary *)obj2 className:(NSString *)className {
    BOOL supportedKVO = [self isSupportKVO:obj1];
    NSUInteger count1 = [obj1 count];
    NSUInteger count2 = [obj2 count];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(count) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    if (supportedKVO) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), [@"NSKVONotifying_" stringByAppendingString:className]);
    } else {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
        XCTAssertEqual(error.code, 11);
        XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    }
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], supportedKVO ? @"KVOed_swiftHook": @"normal");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, supportedKVO ? @[@1] : @[]);
    
    [expectation removeAllObjects];
    XCTAssertEqual([obj2 count], count2);
    XCTAssertEqualObjects(expectation, @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    if ([[self unsuport_KVO_cancellation_class_names] containsObject:className]) {
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), [@"NSKVONotifying_" stringByAppendingString:className]);
        XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"KVOed_normal");
    } else {
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
        XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    }
}

- (void)test_all_instances_NSDictionary{
    [self utilities_test_all_instances_NSDictionary:@"__NSDictionary0" obj:@{}];
    [self utilities_test_all_instances_NSDictionary:@"__NSSingleEntryDictionaryI" obj:@{@"key": @1}];
    [self utilities_test_all_instances_NSDictionary:@"__NSDictionaryI" obj:@{@"key1": @1, @"key2": @2}];
    [self utilities_test_all_instances_NSDictionary:@"__NSDictionaryM" obj:[@{@"key1": @1, @"key2": @2, @"key3": @3} mutableCopy]];
}

- (void)utilities_test_all_instances_NSDictionary:(NSString *)className obj:(NSDictionary *)obj {
    NSUInteger count = [obj count];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(count) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 0);
}

// MARK: NSSet

- (void)test_NSSet {
    [self utilities_test_NSSet_obj1:[[NSSet alloc] init] obj2:[[NSSet alloc] init] className:@"__NSSetI"];
    [self utilities_test_NSSet_obj1:[[NSSet alloc] initWithObjects:@1, nil] obj2:[[NSSet alloc] initWithObjects:@1, nil] className:@"__NSSingleObjectSetI"];
    [self utilities_test_NSSet_obj1:[[NSSet alloc] initWithObjects:@1, @2, nil] obj2:[[NSSet alloc] initWithObjects:@1, @2, nil] className:@"__NSSetI"];
    [self utilities_test_NSSet_obj1:[[NSMutableSet alloc] init] obj2:[[NSMutableSet alloc] init] className:@"__NSSetM"];
    [self utilities_test_NSSet_obj1:[[NSMutableSet alloc] initWithObjects:@1, nil] obj2:[[NSMutableSet alloc] initWithObjects:@1, nil] className:@"__NSSetM"];
    [self utilities_test_NSSet_obj1:[[NSMutableSet alloc] initWithObjects:@1, @2, nil] obj2:[[NSMutableSet alloc] initWithObjects:@1, @2, nil] className:@"__NSSetM"];
}

- (void)utilities_test_NSSet_obj1:(NSSet *)obj1 obj2:(NSSet *)obj2 className:(NSString *)className {
    NSUInteger count1 = [obj1 count];
    NSUInteger count2 = [obj2 count];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(count) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 11);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);
    
    [expectation removeAllObjects];
    XCTAssertEqual([obj2 count], count2);
    XCTAssertEqualObjects(expectation, @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);
    
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
}

- (void)test_all_instances_NSSet{
    [self utilities_test_all_instances_NSSet:@"__NSSetI" obj:[[NSSet alloc] init]];
    [self utilities_test_all_instances_NSSet:@"__NSSingleObjectSetI" obj:[[NSSet alloc] initWithObjects:@1, nil]];
    [self utilities_test_all_instances_NSSet:@"__NSSetI" obj:[[NSSet alloc] initWithObjects:@1, @2, nil]];
    [self utilities_test_all_instances_NSSet:@"__NSSetM" obj:[[NSMutableSet alloc] init]];
    [self utilities_test_all_instances_NSSet:@"__NSSetM" obj:[[NSMutableSet alloc] initWithObjects:@1, nil]];
    [self utilities_test_all_instances_NSSet:@"__NSSetM" obj:[[NSMutableSet alloc] initWithObjects:@1, @2, nil]];
}

- (void)utilities_test_all_instances_NSSet:(NSString *)className obj:(NSSet *)obj {
    NSUInteger count = [obj count];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(count) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 0);
}

// MARK: NSOrderedSet

- (void)test_NSOrderedSet {
    [self utilities_test_NSOrderedSet_obj1:[[NSOrderedSet alloc] init] obj2:[[NSOrderedSet alloc] init] className:@"__NSOrderedSetI"];
    [self utilities_test_NSOrderedSet_obj1:[[NSOrderedSet alloc] initWithObject:@1] obj2:[[NSOrderedSet alloc] initWithObject:@1] className:@"__NSOrderedSetI"];
    [self utilities_test_NSOrderedSet_obj1:[[NSOrderedSet alloc] initWithObjects:@1, @2, nil] obj2:[[NSOrderedSet alloc] initWithObjects:@1, @2, nil] className:@"__NSOrderedSetI"];
    [self utilities_test_NSOrderedSet_obj1:[[NSMutableOrderedSet alloc] init] obj2:[[NSMutableOrderedSet alloc] init] className:@"__NSOrderedSetM"];
    [self utilities_test_NSOrderedSet_obj1:[[NSMutableOrderedSet alloc] initWithObject:@1] obj2:[[NSMutableOrderedSet alloc] initWithObject:@1] className:@"__NSOrderedSetM"];
    [self utilities_test_NSOrderedSet_obj1:[[NSMutableOrderedSet alloc] initWithObjects:@1, @2, nil] obj2:[[NSMutableOrderedSet alloc] initWithObjects:@1, @2, nil] className:@"__NSOrderedSetM"];
}

- (void)utilities_test_NSOrderedSet_obj1:(NSOrderedSet *)obj1 obj2:(NSOrderedSet *)obj2 className:(NSString *)className {
    NSUInteger count1 = [obj1 count];
    NSUInteger count2 = [obj2 count];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(count) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 11);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(count));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);
    
    [expectation removeAllObjects];
    XCTAssertEqual([obj2 count], count2);
    XCTAssertEqualObjects(expectation, @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    XCTAssertEqual([obj1 count], count1);
    XCTAssertEqualObjects(expectation, @[]);
    
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
}

- (void)test_all_instances_NSOrderedSet{
    [self utilities_test_all_instances_NSOrderedSet:@"__NSOrderedSetI" obj:[[NSOrderedSet alloc] init]];
    [self utilities_test_all_instances_NSOrderedSet:@"__NSOrderedSetI" obj:[[NSOrderedSet alloc] initWithObject:@1]];
    [self utilities_test_all_instances_NSOrderedSet:@"__NSOrderedSetI" obj:[[NSOrderedSet alloc] initWithObjects:@1, @2, nil]];
    [self utilities_test_all_instances_NSOrderedSet:@"__NSOrderedSetM" obj:[[NSMutableOrderedSet alloc] init]];
    [self utilities_test_all_instances_NSOrderedSet:@"__NSOrderedSetM" obj:[[NSMutableOrderedSet alloc] initWithObject:@1]];
    [self utilities_test_all_instances_NSOrderedSet:@"__NSOrderedSetM" obj:[[NSMutableOrderedSet alloc] initWithObjects:@1, @2, nil]];
}

- (void)utilities_test_all_instances_NSOrderedSet:(NSString *)className obj:(NSOrderedSet *)obj {
    NSUInteger count = [obj count];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(count) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(count));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqual([obj count], count);
    XCTAssertEqual(expectation, 0);
}

// MARK: NSOperation

- (void)test_NSOperation {
    NSString *className = @"NSOperation";
    NSOperation *obj1 = [[NSOperation alloc] init];
    NSOperation *obj2 = [[NSOperation alloc] init];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(setName:));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(setName:) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNil(error);
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), [@"NSKVONotifying_" stringByAppendingString:className]);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"KVOed_swiftHook");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(setName:));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    obj1.name = @"name1";
    XCTAssertEqualObjects(obj1.name, @"name1");
    XCTAssertEqualObjects(expectation, @[@1]);
    
    [expectation removeAllObjects];
    obj2.name = @"name2";
    XCTAssertEqualObjects(obj2.name, @"name2");
    XCTAssertEqualObjects(expectation, @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    obj1.name = @"name3";
    XCTAssertEqualObjects(obj1.name, @"name3");
    XCTAssertEqualObjects(expectation, @[]);
    
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    if ([[self unsuport_KVO_cancellation_class_names] containsObject:className]) {
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), [@"NSKVONotifying_" stringByAppendingString:className]);
        XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"KVOed_normal");
    } else {
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
        XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    }
}

- (void)test_all_instances_NSOperation{
    NSString *className = @"NSOperation";
    NSOperation *obj = [[NSOperation alloc] init];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(setName:));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(setName:) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(setName:));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    obj.name = @"name1";
    XCTAssertEqualObjects(obj.name, @"name1");
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    obj.name = @"name2";
    XCTAssertEqualObjects(obj.name, @"name2");
    XCTAssertEqual(expectation, 0);
}

// MARK: NSOperationQueue

- (void)test_NSOperationQueue {
    NSString *className = @"NSOperationQueue";
    NSOperationQueue *obj1 = [[NSOperationQueue alloc] init];
    NSOperationQueue *obj2 = [[NSOperationQueue alloc] init];
    Class originalClass = object_getClass(obj1);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(setName:));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];
    NSInteger contextCount = [SwiftUtilitiesOCAPI overrideMethodContextCount];

    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    XCTAssertEqualObjects(NSStringFromClass([obj2 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj2)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj2], @"normal");

    NSError *error = nil;
    OCToken *token = [obj1 sh_hookAfterSelector:@selector(setName:) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNil(error);
    XCTAssertEqual([SwiftUtilitiesOCAPI overrideMethodContextCount], contextCount + 1);
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), [@"NSKVONotifying_" stringByAppendingString:className]);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"KVOed_swiftHook");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(setName:));
    XCTAssertEqual(originalIMP, newIMP);

    [expectation removeAllObjects];
    obj1.name = @"name1";
    XCTAssertEqualObjects(obj1.name, @"name1");
    XCTAssertEqualObjects(expectation, @[@1]);
    
    [expectation removeAllObjects];
    obj2.name = @"name2";
    XCTAssertEqualObjects(obj2.name, @"name2");
    XCTAssertEqualObjects(expectation, @[]);

    [expectation removeAllObjects];
    [token cancelHook];
    obj1.name = @"name3";
    XCTAssertEqualObjects(obj1.name, @"name3");
    XCTAssertEqualObjects(expectation, @[]);
    
    XCTAssertEqualObjects(NSStringFromClass([obj1 class]), className);
    if ([[self unsuport_KVO_cancellation_class_names] containsObject:className]) {
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), [@"NSKVONotifying_" stringByAppendingString:className]);
        XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"KVOed_normal");
    } else {
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj1)), className);
        XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj1], @"normal");
    }
}

- (void)test_all_instances_NSOperationQueue{
    NSString *className = @"NSOperationQueue";
    NSOperationQueue *obj = [[NSOperationQueue alloc] init];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(setName:));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(setName:) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    IMP newIMP = class_getMethodImplementation(class, @selector(setName:));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    obj.name = @"name1";
    XCTAssertEqualObjects(obj.name, @"name1");
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    obj.name = @"name2";
    XCTAssertEqualObjects(obj.name, @"name2");
    XCTAssertEqual(expectation, 0);
}

// MARK: NSURL

- (void)test_URL {
    [self utilities_test_NSURL_obj:[[NSURL alloc] initWithString:@"https://www.google.com"] className:@"NSURL"];
    [self utilities_test_NSURL_obj:[[MyURL43212231212 alloc] initWithString:@"https://www.google.com"] className:@"MyURL43212231212"];
}

- (void)utilities_test_NSURL_obj:(NSURL *)obj className:(NSString *)className {
    Class originalClass = object_getClass(obj);
    IMP originalIMP = class_getMethodImplementation(originalClass, @selector(host));
    XCTAssertFalse(originalIMP == NULL);
    NSMutableArray<NSNumber *> *expectation = [[NSMutableArray<NSNumber *> alloc] init];

    XCTAssertEqualObjects(NSStringFromClass([obj class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj], @"normal");
    
    NSError *error = nil;
    OCToken *token = [obj sh_hookAfterSelector:@selector(host) error:&error closure:^{
        [expectation addObject:@1];
    }];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"SwiftHook.SwiftHookError");
    XCTAssertEqual(error.code, 11);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to hook a instance which is not support KVO.");
    XCTAssertEqualObjects(NSStringFromClass([obj class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj], @"normal");
    IMP newIMP = class_getMethodImplementation(originalClass, @selector(host));
    XCTAssertEqual(originalIMP, newIMP);
    
    [expectation removeAllObjects];
    XCTAssertEqualObjects([obj host], @"www.google.com");
    XCTAssertEqualObjects(expectation, @[]);
    
    [expectation removeAllObjects];
    [token cancelHook];
    XCTAssertEqualObjects([obj host], @"www.google.com");
    XCTAssertEqualObjects(expectation, @[]);
    
    XCTAssertEqualObjects(NSStringFromClass([obj class]), className);
    XCTAssertEqualObjects(NSStringFromClass(object_getClass(obj)), className);
    XCTAssertEqualObjects([SwiftUtilitiesOCAPI getObjectTypeWithObject:obj], @"normal");
}

- (void)test_all_instances_NSURL{
    NSString *className = @"NSURL";
    
    NSURL *obj = [[NSURL alloc] initWithString:@"https://www.google.com"];
    Class class = NSClassFromString(className);
    __block NSInteger expectation = 0;
    IMP originalIMP = class_getMethodImplementation(class, @selector(host));
    XCTAssertFalse(originalIMP == NULL);
    NSError *error = nil;
    OCToken *token = [class sh_hookAfterSelector:@selector(host) error:&error closure:^{
        expectation ++;
    }];
    XCTAssertNil(error);
    
    IMP newIMP = class_getMethodImplementation(class, @selector(host));
    XCTAssertNotEqual(originalIMP, newIMP);

    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqualObjects(obj.host, @"www.google.com");
    XCTAssertEqual(expectation, 1);

    [token cancelHook];
    expectation = 0;
    XCTAssertEqual(object_getClass(obj), class);
    XCTAssertEqualObjects(obj.host, @"www.google.com");
    XCTAssertEqual(expectation, 0);
}

// MARK: others

- (NSArray<NSString *> *)unsuport_KVO_cancellation_class_names {
    NSArray *objects = @[[@{@"key1": @1, @"key2": @2} mutableCopy],
                         [[NSOperation alloc] init],
                         [[NSOperationQueue alloc] init]];
    NSMutableArray<NSString *> *result = [[NSMutableArray<NSString *> alloc] init];
    
    for (NSObject *object in objects) {
        Class before = object_getClass(object);
        NSString *name = NSStringFromClass(before);
        [object addObserver:self forKeyPath:@"hahaha" options:NSKeyValueObservingOptionNew context:NULL];
        Class after = object_getClass(object);
        if (before == after) {
            continue;
        }
        XCTAssertEqualObjects(NSStringFromClass(object_getClass(object)), [@"NSKVONotifying_" stringByAppendingString:name]);
        [object removeObserver:self forKeyPath:@"hahaha"];
        Class original = object_getClass(object);
        if (before != original) {
            [result addObject:name];
            XCTAssertEqualObjects(NSStringFromClass(object_getClass(object)), [@"NSKVONotifying_" stringByAppendingString:name]);
        } else {
            XCTAssertEqualObjects(NSStringFromClass(object_getClass(object)), name);
        }
    }
    
    return result;
}

-(BOOL)isSupportKVO:(NSObject *)object {
    Class before = object_getClass(object);
    NSString *className = NSStringFromClass(before);
    if ([[self unsuport_KVO_cancellation_class_names] containsObject:className]) {
        return YES;
    }
    [object addObserver:self forKeyPath:@"hahaha" options:NSKeyValueObservingOptionNew context:NULL];
    Class after = object_getClass(object);
    [object removeObserver:self forKeyPath:@"hahaha"];
    Class original = object_getClass(object);
    XCTAssertEqual(before, original);
    return before != after;
}


@end
