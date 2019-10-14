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

- (void)simpleMethod;

- (void)executedBlock:(nullable void(^)(void))block;

- (id)returnParameter:(id)value;

+ (void)classSimpleMethod;

@end

NS_ASSUME_NONNULL_END
