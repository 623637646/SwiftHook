//
//  LibffiTestsOC.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 20/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <SwiftHookTests-Swift.h>
@import libffi;

@interface LibffiTestsOC : XCTestCase

@end

@implementation LibffiTestsOC

- (void)testFFICall {
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint64, &ffi_type_sint64};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_sint64, argumentTypes);
    
    TestObject *testObject = [[TestObject alloc] init];
    SEL selector = @selector(sumFuncWithA:b:);
    NSInteger arg1 = 123;
    NSInteger arg2 = 456;
    void *arguments[] = {&testObject, &selector, &arg1, &arg2};
    
    IMP imp = [testObject methodForSelector:selector];
    
    NSInteger retValue;
    ffi_call(&cif, imp, &retValue, arguments);
    XCTAssertEqual(retValue, [testObject sumFuncWithA:arg1 b:arg2]);
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
    ffi_prep_closure_loc(closure, &cif, closureRerewrite, NULL, &newIMP);

    Method method = class_getInstanceMethod([TestObject class], @selector(sumFuncWithA:b:));
    method_setImplementation(method, newIMP);

    // after hook
    TestObject *testObject = [TestObject new];
    NSInteger ret = [testObject sumFuncWithA:123 b:456];
    XCTAssertEqual(ret, 123 * 456);
    
}

static void closureCallOriginal(ffi_cif *cif, void *ret, void **args, void *userdata) {
    ffi_call(cif, userdata, ret, args);
}

- (void)testFFIClosureCallOriginal {
    Method method = class_getInstanceMethod([TestObject class], @selector(sumFuncWithA:b:));
    IMP originalIMP =  method_getImplementation(method);
    
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint64, &ffi_type_sint64};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_sint64, argumentTypes);

    IMP newIMP;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&newIMP);
    ffi_prep_closure_loc(closure, &cif, closureCallOriginal, originalIMP, &newIMP);
   
    method_setImplementation(method, newIMP);

    // after hook
    TestObject *testObject = [TestObject new];
    NSInteger ret = [testObject sumFuncWithA:123 b:456];
    XCTAssertEqual(ret, 123 + 456);
}

@end
