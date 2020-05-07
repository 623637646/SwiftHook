//
//  SHMethodSignature.h
//  SwiftHook
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHMethodSignature : NSObject

+ (nullable SHMethodSignature *)signatureWithMethod:(Method)method;

+ (nullable SHMethodSignature *)signatureWithBlock:(id)block;

@property (readonly) NSArray<NSString *> *argumentTypes;

@property (readonly) NSString *methodReturnType;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
