//
//  ViewController.m
//  SFLockDemo
//
//  Created by Jone on 08/11/2016.
//  Copyright © 2016 Delan. All rights reserved.
//

#import "ViewController.h"
#import <pthread/pthread.h>

@interface ViewController ()

@end

@implementation ViewController {
    dispatch_semaphore_t _semophore;
    pthread_mutex_t _mutex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _semophore = dispatch_semaphore_create(1);
    pthread_mutex_init(&_mutex, NULL);
    
    for (int i = 0; i < 10; ++i) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self semaphore:i];
            [self pthreadMutexT:i];
        });
    }
}

// dispatch_semaphore_t
- (void)semaphore:(int)index {
    // sign = 1 当 = 0 时 -1 变为负数就不能再往下执行了。
    long success = dispatch_semaphore_wait(_semophore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"success = %ld, semaphore = %d", success, index);
    
    dispatch_semaphore_signal(_semophore);
}

// phread_mutex_t
- (void)pthreadMutexT:(int)index {
    pthread_mutex_lock(&_mutex);
    NSLog(@"phread_mutex_t: %d", index);
    pthread_mutex_unlock(&_mutex);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
