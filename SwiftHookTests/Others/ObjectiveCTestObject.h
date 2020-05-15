//
//  ObjectiveCTestObject.h
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectiveCTestObject : NSObject

- (void)noArgsNoReturnFunc;

- (NSInteger)sumFuncWithA:(NSInteger)a b:(NSInteger)b;

@end

NS_ASSUME_NONNULL_END
