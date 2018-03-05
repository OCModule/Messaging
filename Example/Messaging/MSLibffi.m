//
//  MSLibffi.m
//  Messaging_Example
//
//  Created by Steve on 04/03/2018.
//  Copyright © 2018 wangchengqvan@gmail.com. All rights reserved.
//

#import "MSLibffi.h"
#import <libffi-core/ffi.h>


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



@implementation MSLibffi

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

@end
