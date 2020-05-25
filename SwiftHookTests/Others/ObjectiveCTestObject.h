//
//  ObjectiveCTestObject.h
//  SwiftHookTests
//
//  Created by Yanni Wang on 15/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectiveCSuperTestObject : NSObject

- (void)superFunc;

@end

@interface ObjectiveCTestObject : ObjectiveCSuperTestObject

@property(nonatomic, assign) NSInteger number;

@property(nonatomic, copy, nullable) void(^deallocExecution)(void);

- (void)noArgsNoReturnFunc;

- (NSInteger)sumFuncWithA:(NSInteger)a b:(NSInteger)b;

+ (void)classNoArgsNoReturnFunc;

@end

NS_ASSUME_NONNULL_END
