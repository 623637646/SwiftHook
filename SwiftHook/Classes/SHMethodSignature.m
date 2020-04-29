//
//  SHMethodSignature.m
//  SwiftHook
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "SHMethodSignature.h"

@interface SHMethodSignature()

@property (nonatomic, strong) NSMethodSignature *trueMethodSignature;

@end

@implementation SHMethodSignature

+ (nullable SHMethodSignature *)signatureWithObjCTypes:(const char *)types
{
    return [[self alloc] initWithObjCTypes:types];
}

- (instancetype)initWithObjCTypes:(const char *)types
{
    NSMethodSignature *trueMethodSignature = [NSMethodSignature signatureWithObjCTypes:types];
    if (!trueMethodSignature) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.trueMethodSignature = trueMethodSignature;
    }
    return self;
}

- (NSArray<NSString *> *)argumentsType
{
    NSUInteger numberOfArguments = self.trueMethodSignature.numberOfArguments;
    NSMutableArray *argumentsType = [[NSMutableArray alloc] initWithCapacity:numberOfArguments];
    for (int i = 0; i < numberOfArguments; i++) {
        [argumentsType addObject:[[NSString alloc] initWithUTF8String:[self.trueMethodSignature getArgumentTypeAtIndex:i]]];
    }
    return [argumentsType copy];
}

- (NSString *)methodReturnType
{
    return [[NSString alloc] initWithUTF8String:self.trueMethodSignature.methodReturnType];
}

@end
