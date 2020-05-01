//
//  ComplexityStruct.h
//  SwiftHookTests
//
//  Created by Yanni Wang on 2/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#ifndef ComplexityStruct_h
#define ComplexityStruct_h

struct ComplexityStruct {
    int i;
    struct {
        double d;
        struct {
            void *p;
            struct {
            } s;
        } s;
    } s;
};

#endif /* ComplexityStruct_h */
