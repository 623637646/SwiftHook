//
//  TestObject.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

- (void)simpleMethod
{
    
}

- (void)executedBlock:(nullable void(^)(void))block
{
    if (block) {
        block();
    }
}

- (id)returnParameter:(id)value;
{
    return value;
}

+ (void)classSimpleMethod
{
    
}

@end
