//
//  main.m
//  Messaging
//
//  Created by wangchengqvan@gmail.com on 03/02/2018.
//  Copyright (c) 2018 wangchengqvan@gmail.com. All rights reserved.
//

@import UIKit;
#import "MSAppDelegate.h"
#import "fishhook.h"

static int (*original_strlen)(const char *__s);

int new_strlen(const char *__s) {
//    printf(" Aop now !!");
    return original_strlen(__s);
}

int main(int argc, char * argv[])
{
    @autoreleasepool {
        /* ------------ fishhook --------------- */
    char *str = "hello fishhook";
    struct rebinding strlen_rebinding = { "strlen", new_strlen, (void *)&original_strlen };
    rebind_symbols((struct rebinding[1]){strlen_rebinding}, 1);
    long result = strlen(str);
    printf("result == :%ld\n",result);
        
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([MSAppDelegate class]));
    }
}

