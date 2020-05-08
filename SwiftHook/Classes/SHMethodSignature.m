//
//  SHMethodSignature.m
//  SwiftHook
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "SHMethodSignature.h"
#import <SwiftHook/SwiftHook.h>

@interface SHMethodSignature()

@property (nonatomic, strong) NSMethodSignature *methodSignature;

@end

@implementation SHMethodSignature

+ (nullable SHMethodSignature *)signatureWithMethod:(Method)method
{
    const char *types = method_getTypeEncoding(method);
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:types];
    if (!methodSignature) {
        return nil;
    }
    return [[self alloc] initWithMethodSignature:methodSignature];
}

+ (nullable SHMethodSignature *)signatureWithBlock:(id)block
{
    if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
        return nil;
    }
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:sh_blockSignature(block)];
    if (!methodSignature) {
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

- (NSArray<NSString *> *)argumentTypes
{
    NSUInteger numberOfArguments = self.methodSignature.numberOfArguments;
    NSMutableArray *argumentTypes = [[NSMutableArray alloc] initWithCapacity:numberOfArguments];
    for (int i = 0; i < numberOfArguments; i++) {
        NSString *argumentType = [[NSString alloc] initWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:i]];
        [argumentTypes addObject: [self ignoreUnusedChar:argumentType]];
    }
    return [argumentTypes copy];
}

- (NSString *)returnType
{
    return [self ignoreUnusedChar:[[NSString alloc] initWithUTF8String:self.methodSignature.methodReturnType]];
}

static NSRegularExpression *regex;
- (NSString *)ignoreUnusedChar:(NSString *)type
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\\".+?\\\"|\\<.+?\\>" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    NSMutableString *result = [[NSMutableString alloc] initWithString:type];
    [regex replaceMatchesInString:result options:0 range:NSMakeRange(0, result.length) withTemplate:@""];
    return [result copy];
}

@end
