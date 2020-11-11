//
//  ObjectiveCTestObject.m
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "ObjectiveCTestObject.h"

@implementation ObjectiveCSuperTestObject

- (void)superFunc
{
    
}

@end

@implementation ObjectiveCTestObject

- (void)dealloc
{
    if (self.deallocExecution) {
        self.deallocExecution();
    }
}

- (void)noArgsNoReturnFunc
{
    
}

- (NSInteger)sumFuncWithA:(NSInteger)a b:(NSInteger)b
{
    return a + b;
}

+ (void)classNoArgsNoReturnFunc
{
    
}

- (NSString *)getSelfNumberPlusCMD
{
    return [NSString stringWithFormat:@"%@+%@", @(self.number), NSStringFromSelector(_cmd)];
}

- (void)testPoint:(CGPoint)point
{
    
}

- (void)setEmptyStruct:(InternalEmptyStruct)emptyStruct
{
    
}

- (InternalEmptyStruct)getEmptyStruct
{
    return (InternalEmptyStruct){};
}

@end
