//
//  SHFFITypeContext.h
//  SwiftHook
//
//  Created by Yanni Wang on 1/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>
@import libffi_iOS;

NS_ASSUME_NONNULL_BEGIN

@interface SHFFITypeContext : NSObject

@property (nonatomic, assign, readonly) ffi_type *ffiType;

+ (nullable instancetype)contextWithTypeEncodingString:(NSString *)typeEncoding;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
