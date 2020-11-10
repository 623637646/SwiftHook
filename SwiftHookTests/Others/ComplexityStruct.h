//
//  ComplexityStruct.h
//  SwiftHookTests
//
//  Created by Yanni Wang on 2/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#ifndef ComplexityStruct_h
#define ComplexityStruct_h
#import <UIKit/UIKit.h>

struct ComplexityStruct {
    int i;
    CGPoint p;
    CGRect frame;
    struct {
        double d;
        struct {
            void *p;
            struct {
                float c;
            } s;
        } s;
    } s;
};

struct BigStruct {
    CGRect frame1;
    CGRect frame2;
    CGRect frame3;
    CGRect frame4;
    CGRect frame5;
    CGRect frame6;
    CGRect frame7;
    CGRect frame8;
    CGRect frame9;
    CGRect frame10;
    CGRect frame11;
    CGRect frame12;
};

struct EmptyStruct {
    
};

struct InternalEmptyStruct {
    int i;
    struct {
    } s;
};

#endif /* ComplexityStruct_h */
