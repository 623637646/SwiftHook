//
//  BlockUtilities.m
//  SwiftHook
//
//  Created by Yanni Wang on 8/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "BlockUtilities.h"
#import <objc/runtime.h>

// Refer to: https://clang.llvm.org/docs/Block-ABI-Apple.html
enum {
    // Set to true on blocks that have captures (and thus are not true
    // global blocks) but are known not to escape for various other
    // reasons. For backward compatibility with old runtimes, whenever
    // BLOCK_IS_NOESCAPE is set, BLOCK_IS_GLOBAL is set too. Copying a
    // non-escaping block returns the original block and releasing such a
    // block is a no-op, which is exactly how global blocks are handled.
    BLOCK_IS_NOESCAPE      =  (1 << 23),
    
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

// Refer to: https://clang.llvm.org/docs/Block-ABI-Apple.html
struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

const char * _Nullable sh_blockSignature(id block)
{
    struct Block_literal_1 *layout = (__bridge void *)block;
    if (!(layout->flags & BLOCK_HAS_SIGNATURE))
        return nil;
    
    void *descRef = layout->descriptor;
    descRef += 2 * sizeof(unsigned long int);
    
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE)
        descRef += 2 * sizeof(void *);
    
    if (!descRef) return nil;
    
    const char *signature = (*(const char **)descRef);
    return signature;
}

void (*sh_blockInvoke(id block))(void *, ...)
{
    struct Block_literal_1 *layout = (__bridge void *)block;
    return layout->invoke;
}

@interface OriginalClosureForInsteadContext : NSObject

@property (nonatomic, weak) id targetObject;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalIMP;
@property (nonatomic, assign) ffi_cif *originalCifPointer;

@property (nonatomic, assign) ffi_type **argumentTypes;
@property (nonatomic, assign) void (*invokeIMP)(void *, ...);
@property (nonatomic, assign) ffi_cif *closureCifPointer;
@property (nonatomic, assign) ffi_closure *closure;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

void closureFunction(ffi_cif *cif, void *ret, void **args, void *userdata) {
    OriginalClosureForInsteadContext *context = (__bridge OriginalClosureForInsteadContext *)(userdata);
    int nargs = cif->nargs + 1;
    void **newArgs = malloc(sizeof(void *) * nargs);
    newArgs[0] = (__bridge void *)(context.targetObject);
    newArgs[1] = context.selector;
    for (int i = 2; i <= nargs - 1; i++) {
        newArgs[i] = args[i - 1];
    }
    ffi_call(context.originalCifPointer, context.originalIMP, ret, newArgs);
    free(newArgs);
}

@implementation OriginalClosureForInsteadContext

- (instancetype)initWithTargetObject:(id)targetObject selector:(SEL)selector originalIMP:(IMP)originalIMP originalCifPointer:(ffi_cif *)originalCifPointer
{
    self = [super init];
    if (self) {
        self.targetObject = targetObject;
        self.selector = selector;
        self.originalIMP = originalIMP;
        self.originalCifPointer = originalCifPointer;
        
        int nargs = originalCifPointer->nargs - 1;
        self.argumentTypes = malloc(sizeof(ffi_type *) * nargs);
        self.argumentTypes[0] = &ffi_type_pointer;
        for (int i = 1; i <= nargs - 1; i++) {
            self.argumentTypes[i] = originalCifPointer->arg_types[i + 1];
        }
        self.closureCifPointer = malloc(sizeof(ffi_cif));
        ffi_status status = ffi_prep_cif(self.closureCifPointer, FFI_DEFAULT_ABI, nargs, originalCifPointer->rtype, self.argumentTypes);
        if (status != FFI_OK) {
            return nil;
        }
        void (*invokeIMP)(void *, ...);
        self.closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&invokeIMP);
        
        status = ffi_prep_closure_loc(self.closure, self.closureCifPointer, closureFunction, (__bridge void *)(self), &invokeIMP);
        if (status != FFI_OK) {
            return nil;
        }
        self.invokeIMP = invokeIMP;
    }
    return self;
}

- (void)dealloc
{
    ffi_closure_free(self.closure);
    free(self.closureCifPointer);
    free(self.argumentTypes);
}

@end

id _Nullable createOriginalClosureForInstead(id targetObject, SEL selector, IMP originalIMP, ffi_cif *cifPointer)
{
    OriginalClosureForInsteadContext *context = [[OriginalClosureForInsteadContext alloc] initWithTargetObject:targetObject selector:selector originalIMP:originalIMP originalCifPointer:cifPointer];
    if (context == nil) {
        return nil;
    }
    
    // TODO: Why crash?
//    id block = ^{
//
//    };
//    objc_setAssociatedObject(block, "createOriginalClosureForInstead", context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    struct Block_literal_1 *layout = (__bridge void *)block;
//    layout->invoke = context.invokeIMP;
    
    
    struct Block_literal_1 *layout = malloc(sizeof(struct Block_literal_1));
    *layout = *(__bridge struct Block_literal_1 *)(^{});
    layout->invoke = context.invokeIMP;
    id block = (__bridge_transfer id)(layout);
    objc_setAssociatedObject(block, "createOriginalClosureForInstead", context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return block;
}
