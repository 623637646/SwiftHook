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

void sh_setBlockInvoke(id block, void (*blockInvoke)(void *, ...))
{
    struct Block_literal_1 *layout = (__bridge void *)block;
    layout->invoke = blockInvoke;
}
