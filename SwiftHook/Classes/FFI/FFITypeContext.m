//
//  FFITypeContext.m
//  SwiftHook
//
//  Created by Yanni Wang on 1/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

#import "FFITypeContext.h"

@interface FFITypeContext()

@property (nonatomic, assign, readwrite) ffi_type *ffiType;
@property (nonatomic, strong) NSPointerArray *mallocArray;

@end

@implementation FFITypeContext

+ (nullable instancetype)contextWithTypeEncodingString:(NSString *)typeEncoding;
{
    __block FFITypeContext *context = [[self alloc] initWithTypeEncoding:typeEncoding.UTF8String];
    // Return default static instance when the typeEncoding is non-struct to save memory.
    [[self defaultContext] enumerateObjectsUsingBlock:^(FFITypeContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (context.ffiType == obj.ffiType) {
            context = obj;
            *stop = YES;
        }
    }];
    return context;
}

+ (NSArray<FFITypeContext *> *)defaultContext
{
    static NSArray<FFITypeContext *> *defaultContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultContext = @[
            ^{
                FFITypeContext *context = [[FFITypeContext alloc] init];
                context.ffiType = &ffi_type_void;
                return context;
            }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_uint8;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_sint8;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_uint16;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_sint16;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_uint32;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_sint32;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_uint64;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_sint64;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_float;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_double;
                 return context;
             }(),
             ^{
                 FFITypeContext *context = [[FFITypeContext alloc] init];
                 context.ffiType = &ffi_type_pointer;
                 return context;
             }(),
        ];
    });
    return defaultContext;
}

- (nullable instancetype)initWithTypeEncoding:(const char *)typeEncoding;
{
    self = [super init];
    if (self) {
        self.mallocArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory];
        ffi_type *ffiType = [self ffiTypeForEncode:typeEncoding];
        if (ffiType == NULL) {
            return nil;
        }
        self.ffiType = ffiType;
    }
    return self;
}

- (void)dealloc
{
    for (int i = 0; i < self.mallocArray.count; i++) {
        void *point = [self.mallocArray pointerAtIndex:i];
        if (!point) {
            break;
        }
        free(point);
    }
}

// Refer: https://github.com/yulingtianxia/BlockHook/blob/master/BlockHook/BlockHook.m
- (ffi_type *)ffiTypeForEncode:(const char *)str
{
    #define SINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            if(sizeof(type) == 1) \
                return &ffi_type_sint8; \
            else if(sizeof(type) == 2) \
                return &ffi_type_sint16; \
            else if(sizeof(type) == 4) \
                return &ffi_type_sint32; \
            else if(sizeof(type) == 8) \
                return &ffi_type_sint64; \
            else \
            { \
                /* Unknown size for type*/\
            } \
        } \
    } while(0)
    
    #define UINT(type) do { \
        if(str[0] == @encode(type)[0]) \
        { \
            if(sizeof(type) == 1) \
                return &ffi_type_uint8; \
            else if(sizeof(type) == 2) \
                return &ffi_type_uint16; \
            else if(sizeof(type) == 4) \
                return &ffi_type_uint32; \
            else if(sizeof(type) == 8) \
                return &ffi_type_uint64; \
            else \
            { \
                /* Unknown size for type*/\
            } \
        } \
    } while(0)
    
    #define INT(type) do { \
        SINT(type); \
        UINT(unsigned type); \
    } while(0)
    
    #define COND(type, name) do { \
        if(str[0] == @encode(type)[0]) \
        return &ffi_type_ ## name; \
    } while(0)
    
    #define PTR(type) COND(type, pointer)
    
    SINT(_Bool);
    SINT(signed char);
    UINT(unsigned char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    
    PTR(id);
    PTR(Class);
    PTR(SEL);
    PTR(void *);
    PTR(char *);
    
    COND(float, float);
    COND(double, double);
    
    COND(void, void);
    
    // Ignore Method Encodings
    switch (*str) {
        case 'r':
        case 'R':
        case 'n':
        case 'N':
        case 'o':
        case 'O':
        case 'V':
            return [self ffiTypeForEncode:str + 1];
    }
    
    // Struct Type Encodings
    if (*str == '{') {
        ffi_type *structType = [self ffiTypeForStructEncode:str];
        return structType;
    }
    
    // Unknown encode string
    return nil;
}

// Refer:
// http://www.chiark.greenend.org.uk/doc/libffi-dev/html/Type-Example.html
// http://www.chiark.greenend.org.uk/doc/libffi-dev/html/Structures.html
// https://github.com/eleme/Stinger/blob/master/Stinger/Classes/STMethodSignature.m
- (ffi_type *)ffiTypeForStructEncode:(const char *)c
{
    while (c[0] != '=') ++c; ++c;
    NSPointerArray *pointArray = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory];
    while (c[0] != '}') {
        ffi_type *elementType = [self ffiTypeForEncode:c];
        if (elementType) {
            [pointArray addPointer:elementType];
            c = NSGetSizeAndAlignment(c, NULL, NULL);
        } else {
            return NULL;
        }
    }
    
    NSInteger count = pointArray.count;
    ffi_type **elements = malloc(sizeof(ffi_type *) * (count + 1));
    if (elements == NULL) {
        return NULL;
    }
    [self.mallocArray addPointer:elements];
    for (NSInteger i = 0; i < count; i++) {
      elements[i] = [pointArray pointerAtIndex:i];
    }
    elements[count] = NULL; // terminated element is NULL
        
    ffi_type *structType = malloc(sizeof(ffi_type));
    if (structType == NULL) {
        return NULL;
    }
    [self.mallocArray addPointer:structType];
    structType->type = FFI_TYPE_STRUCT;
    structType->elements = elements;
    return structType;
}

@end
