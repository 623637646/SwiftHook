//
//  NSKVONotifying_MyClass.h
//  SwiftHookTests
//
//  Created by Wang Ya on 1/25/21.
//  Copyright © 2021 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyClass : NSObject
@end

@interface NSKVONotifying_MyClass : MyClass
@property (nonatomic, assign) NSInteger swiftHookPrivateProperty;
@property (nonatomic, assign) NSInteger number;
@end

NS_ASSUME_NONNULL_END
