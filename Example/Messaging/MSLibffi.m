//
//  MSLibffi.m
//  Messaging_Example
//
//  Created by Steve on 04/03/2018.
//  Copyright © 2018 wangchengqvan@gmail.com. All rights reserved.
//

#import "MSLibffi.h"
#import <libffi-core/ffi.h>
#import <objc/runtime.h>
// hook ---- instead

typedef struct __NSBlock {
    __unused void *isa;
    int flags;
    __unused int reserved;
    void (__unused *invoke)(struct __NSBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        const char *signature;
        const char *layout;
    } *descriptor;
} *__NSBlockRef;

static NSMethodSignature *BlockSignature(id block, NSError **error) {
    __NSBlockRef layout = (__bridge void *)block;
    if (!(layout->flags)) {
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}

static NSMethodSignature *MethodSignatureFromBlockSignature(NSMethodSignature *blockSignature) {
    NSMutableString *sig = [NSMutableString stringWithFormat:@"%s%s%s", blockSignature.methodReturnType, @encode(id), @encode(SEL)];
    for (NSInteger step = 2; step < blockSignature.numberOfArguments; step++) {
        NSString *argType = [NSString stringWithUTF8String:[blockSignature getArgumentTypeAtIndex:step]];
        [sig appendString:argType];
    }
    return [NSMethodSignature signatureWithObjCTypes:sig.UTF8String];
}

void puts_binding(ffi_cif *cif, unsigned int *ret, void *args[], FILE *stream) {
    *ret = fputs(*(char **)args[0], stream);
}

void closureCalled(ffi_cif *cif, void *ret, void **args, void *userdata) {
    int bar = *((int *)args[2]);
    int baz = *((int *)args[3]);
    *((int *)ret) = bar * baz;
}


@implementation MSLibffi

- (instancetype)init {
    self = [super init];
    if (self) {
        [self testLibffi];
        [self testClosure];
        [self testMehodCall];
        [self testLibffiClosure];
    }
    return self;
}

- (void)testLibffi {
    ffi_cif cif;
    ffi_type *args[1];
    void *values[1];
    char *s;
    int rc;
    args[0] = &ffi_type_pointer;
    values[0] = &s;
    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1, &ffi_type_uint, args) == FFI_OK) {
        s = "hello word";
        ffi_call(&cif, (void *)puts, &rc, values);

        s = "This is cool";
        ffi_call(&cif, (void *)puts, &rc, values);
    }
}

- (void)testClosure {
    ffi_cif cif;
    ffi_type *args[1];
    ffi_closure *closure;
    int (*bound_puts)(char *);
    int rc;
    closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&bound_puts);
    if (closure) {
        args[0] = &ffi_type_pointer;
        if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1, &ffi_type_uint, args) == FFI_OK) {
            if (ffi_prep_closure_loc(closure, &cif, puts_binding, stdout, bound_puts) == FFI_OK) {
                rc = bound_puts("hello closure");
            }
        }
    }
    ffi_closure_free(closure);
}

- (int)sumWithA: (int)a B:(int)b {
    return a + b;
}

- (void)testMehodCall {
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint32, &ffi_type_sint32};
    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_pointer, argumentTypes) == FFI_OK) {
        SEL selector = @selector(sumWithA:B:);
        int a = 123;
        int b = 456;
        void *arguments[] = {&self, &selector, &a, &b};
        IMP imp = [self methodForSelector:selector];
        int retValue;
        ffi_call(&cif, imp, &retValue, arguments);
        printf("\nffi_call: %d, rel-- %d", retValue, [self sumWithA:a B:b]);
    }
}

- (void)testLibffiClosure {
    ffi_cif cif;
    ffi_type *argumentTypes[] = {&ffi_type_pointer, &ffi_type_pointer, &ffi_type_sint32, &ffi_type_sint32};
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 4, &ffi_type_pointer, argumentTypes);
    IMP newIMP;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&newIMP);
    ffi_prep_closure_loc(closure, &cif, closureCalled, NULL, NULL);
    
    Method method = class_getInstanceMethod([self class], @selector(sumWithA:B:));
    method_setImplementation(method, newIMP);
    int a = 123;
    int b = 456;
    SEL selector = @selector(sumWithA:B:);
    void *arguments[] = {&self, &selector, &a, &b};
    // after hook
//    int ret = [self sumWithA:123 B:456];
    int ret;
    ffi_call(&cif, newIMP, &ret, arguments);
    printf("\nffi_closure: %d", ret);
}

@end
