//
//  LibffiTestsOC.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "ObjectiveCTestObject.h"
@import libffi_iOS;

@interface LibffiTestsOC : XCTestCase

@end

@implementation LibffiTestsOC

- (void)testFFICall {
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint64, &ffi_type_sint64};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_sint64, argumentTypes);
    
    ObjectiveCTestObject *testObject = [[ObjectiveCTestObject alloc] init];
    SEL selector = @selector(sumFuncWithA:b:);
    NSInteger arg1 = 123;
    NSInteger arg2 = 456;
    void *arguments[] = {&testObject, &selector, &arg1, &arg2};
    
    IMP imp = [testObject methodForSelector:selector];
    
    NSInteger retValue;
    ffi_call(&cif, imp, &retValue, arguments);
    XCTAssertEqual(retValue, [testObject sumFuncWithA:arg1 b:arg2]);
}

- (void)test_FFICall_Struct {
    ffi_type tm_type;
    ffi_type *tm_type_elements[3];
    
    tm_type.size = tm_type.alignment = 0;
    tm_type.type = FFI_TYPE_STRUCT;
    tm_type.elements = (ffi_type **)&tm_type_elements;
    
    tm_type_elements[0] = &ffi_type_double;
    tm_type_elements[1] = &ffi_type_double;
    tm_type_elements[2] = NULL;
    
    
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &tm_type};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 3, &ffi_type_void, argumentTypes);
    
    ObjectiveCTestObject *testObject = [[ObjectiveCTestObject alloc] init];
    SEL selector = @selector(testPoint:);
    CGPoint arg1 = {11,22};
    void *arguments[] = {&testObject, &selector, &arg1};
    
    IMP imp = [testObject methodForSelector:selector];
    ffi_call(&cif, imp, NULL, arguments);
}

void closureRerewrite(ffi_cif *cif, void *ret, void **args, void *userdata) {
    NSInteger bar = *((NSInteger *)args[2]);
    NSInteger baz = *((NSInteger *)args[3]);
    *((NSInteger *)ret) = bar * baz;
}

- (void)testFFIClosuRerewrite {
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint64, &ffi_type_sint64};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_sint64, argumentTypes);

    IMP newIMP;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&newIMP);
    ffi_prep_closure_loc(closure, &cif, closureRerewrite, NULL, newIMP);

    Method method = class_getInstanceMethod([ObjectiveCTestObject class], @selector(sumFuncWithA:b:));
    IMP originalIMP = method_setImplementation(method, newIMP);

    // after hook
    ObjectiveCTestObject *testObject = [ObjectiveCTestObject new];
    NSInteger ret = [testObject sumFuncWithA:123 b:456];
    XCTAssertEqual(ret, 123 * 456);
    method_setImplementation(method, originalIMP);
    ffi_closure_free(closure);
}

static void closureCallOriginal(ffi_cif *cif, void *ret, void **args, void *userdata) {
    ffi_call(cif, userdata, ret, args);
}

- (void)testFFIClosureCallOriginal {
    Method method = class_getInstanceMethod([ObjectiveCTestObject class], @selector(sumFuncWithA:b:));
    IMP originalIMP =  method_getImplementation(method);
    
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint64, &ffi_type_sint64};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_sint64, argumentTypes);

    IMP newIMP;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&newIMP);
    ffi_prep_closure_loc(closure, &cif, closureCallOriginal, originalIMP, newIMP);
   
    method_setImplementation(method, newIMP);

    // after hook
    ObjectiveCTestObject *testObject = [ObjectiveCTestObject new];
    NSInteger ret = [testObject sumFuncWithA:123 b:456];
    XCTAssertEqual(ret, 123 + 456);
    method_setImplementation(method, originalIMP);
    ffi_closure_free(closure);
}

@end
