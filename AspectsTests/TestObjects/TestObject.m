//
//  TestObject.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

- (void)methodWithExecuted:(BOOL *)executed;
{
    if (executed) {
        *executed = YES;
    }
}

@end
