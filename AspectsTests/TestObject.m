//
//  TestObject.m
//  AspectsTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

- (void)noArgsNoReturnFunc
{
    
}

- (void)execute:(void(^)(void))block
{
    block();
}

- (void)subclassOverridedFunc
{
    [super subclassOverridedFunc];
}

+ (void)classMethod
{
    
}

@end
