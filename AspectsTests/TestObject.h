//
//  TestObject.h
//  AspectsTests
//
//  Created by Yanni Wang on 13/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "SuperTestObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestObject : SuperTestObject

@property(nonatomic) int number;

- (void)noArgsNoReturnFunc;

- (void)execute:(void(^)(void))block;

+ (void)classMethod;

@end

NS_ASSUME_NONNULL_END
