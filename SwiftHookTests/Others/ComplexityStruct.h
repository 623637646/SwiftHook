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

typedef struct {
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
} ComplexityStruct;

typedef struct {
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
} BigStruct;

typedef struct {
    
} EmptyStruct;

typedef struct {
    int i;
    struct {
    } s;
} InternalEmptyStruct;

#endif /* ComplexityStruct_h */
