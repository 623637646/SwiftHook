//
//  iOSHook.m
//  iOSHook
//
//  Created by Yanni Wang on 12/4/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Block1)(void);
typedef void (^Block2)(Block1 block1);
typedef void (*IMPBlockType)(id, SEL, ...);

id iOSHookImplementationBlock(Block2 hookBlock, IMP originalIMP, SEL selector)
{
    return ^(id self, int i, double d, NSString *string){
        hookBlock(^(){
            ((IMPBlockType)originalIMP)(self, selector);
        });
    };
}
