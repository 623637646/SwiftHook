//
//  SHMethodSignature.h
//  SwiftHook
//
//  Created by Yanni Wang on 29/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHMethodSignature : NSObject

+ (nullable SHMethodSignature *)signatureWithObjCTypes:(const char *)types;

+ (nullable SHMethodSignature *)signatureWithBlock:(id)block;

@property (readonly) NSArray<NSString *> *argumentsType;

@property (readonly) NSString *methodReturnType;

@end

NS_ASSUME_NONNULL_END
