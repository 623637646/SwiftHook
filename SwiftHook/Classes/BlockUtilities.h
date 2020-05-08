//
//  BlockUtilities.h
//  SwiftHook
//
//  Created by Yanni Wang on 8/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const char * _Nullable sh_blockSignature(id block);

extern void (*sh_blockInvoke(id block))(void *, ...);

NS_ASSUME_NONNULL_END
