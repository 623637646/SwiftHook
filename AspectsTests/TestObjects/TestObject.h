//
//  TestObject.h
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperTestObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestObject : SuperTestObject

- (void)methodWithExecutedBlock:(nullable void(^)(void))block;

- (id)methodWithOriginalReturnValue:(id)value;

- (NSString *)methodGetNameOfSelf;

@end

NS_ASSUME_NONNULL_END
