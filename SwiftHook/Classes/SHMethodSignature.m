//
//  SHMethodSignature.m
//  SwiftHook
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "SHMethodSignature.h"

// MARK: SHBlockSignature

NSString *const SHBlockSignatureErrorDomain = @"SHBlockSignatureErrorDomain";
typedef NS_OPTIONS(int, SHBlockSignatureBlockFlags) {
    SHBlockSignatureBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    SHBlockSignatureBlockFlagsHasSignature          = (1 << 30)
};
typedef struct _SHBlockSignatureBlock {
    __unused Class isa;
    SHBlockSignatureBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _SHBlockSignatureBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        // requires SHBlockSignatureBlockFlagsHasCopyDisposeHelpers
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        // requires SHBlockSignatureBlockFlagsHasSignature
        const char *signature;
        const char *layout;
    } *descriptor;
    // imported variables
} *SHBlockSignatureBlockRef;

static NSMethodSignature *SHBlockMethodSignature(id block, NSError **error) {
    SHBlockSignatureBlockRef layout = (__bridge void *)block;
    if (!(layout->flags & SHBlockSignatureBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        if (error) {
            *error = [NSError errorWithDomain:SHBlockSignatureErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & SHBlockSignatureBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        if (error) {
            *error = [NSError errorWithDomain:SHBlockSignatureErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}

// MARK: SHMethodSignature

@interface SHMethodSignature()

@property (nonatomic, strong) NSMethodSignature *methodSignature;

@end

@implementation SHMethodSignature

+ (nullable SHMethodSignature *)signatureWithObjCTypes:(const char *)types
{
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:types];
    if (!methodSignature) {
        return nil;
    }
    return [[self alloc] initWithMethodSignature:methodSignature];
}

+ (nullable SHMethodSignature *)signatureWithBlock:(id)block
{
    NSError *error = nil;
    NSMethodSignature *methodSignature = SHBlockMethodSignature(block, &error);
    if (!methodSignature || error) {
        return nil;
    }
    return [[self alloc] initWithMethodSignature: methodSignature];
}

- (instancetype)initWithMethodSignature:(NSMethodSignature *)methodSignature
{
    self = [super init];
    if (self) {
        self.methodSignature = methodSignature;
    }
    return self;
}

- (NSArray<NSString *> *)argumentsType
{
    NSUInteger numberOfArguments = self.methodSignature.numberOfArguments;
    NSMutableArray *argumentsType = [[NSMutableArray alloc] initWithCapacity:numberOfArguments];
    for (int i = 0; i < numberOfArguments; i++) {
        [argumentsType addObject:[[NSString alloc] initWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:i]]];
    }
    return [argumentsType copy];
}

- (NSString *)methodReturnType
{
    return [[NSString alloc] initWithUTF8String:self.methodSignature.methodReturnType];
}

@end
