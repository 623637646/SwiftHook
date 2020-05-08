//
//  BlockUtilities.m
//  SwiftHook
//
//  Created by Yanni Wang on 8/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "BlockUtilities.h"

enum {
  BLOCK_DEALLOCATING =      (0x0001),  // runtime
  BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
  BLOCK_NEEDS_FREE =        (1 << 24), // runtime
  BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
  BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
  BLOCK_IS_GC =             (1 << 27), // runtime
  BLOCK_IS_GLOBAL =         (1 << 28), // compiler
  BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
  BLOCK_HAS_SIGNATURE  =    (1 << 30)  // compiler
};

struct Block_layout {
  void *isa;
  volatile int flags; // contains ref count
  int reserved;
  void (*invoke)(void *, ...);
  struct Block_descriptor_1 *descriptor;
  // imported variables
};

const char * _Nullable sh_blockSignature(id block)
{
    struct Block_layout *layout = (__bridge void *)block;
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
    struct Block_layout *layout = (__bridge void *)block;
    return layout->invoke;
}

