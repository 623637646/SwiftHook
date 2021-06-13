//
//  SHObjectiveCUtilities.h
//  SwiftHook
//
//  Created by Yanni Wang on 8/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const char * _Nullable sh_blockSignature(id block);

extern void (*sh_blockInvoke(id block))(void *, ...);

extern void sh_setBlockInvoke(id block, void (*blockInvoke)(void *, ...));


@interface SwiftHookUtilities: NSObject
+ (BOOL)catchException:(__attribute__((noescape)) void(^)(void))tryBlock error:(__autoreleasing NSError **)error;
@end

NS_ASSUME_NONNULL_END
