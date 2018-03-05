//
//  MSViewController.m
//  Messaging
//
//  Created by wangchengqvan@gmail.com on 03/02/2018.
//  Copyright (c) 2018 wangchengqvan@gmail.com. All rights reserved.
//

#import "MSViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface MSViewController ()

- (void)test;

@end

@implementation MSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    return [NSObject methodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    void *nullPointer = NULL;
    [anInvocation setReturnValue:nullPointer];
}

/**
 通常可以在此函数中进行 log 打印
 */
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"没有找到---%@", NSStringFromSelector(aSelector));
    [super doesNotRecognizeSelector:aSelector];
}

@end
