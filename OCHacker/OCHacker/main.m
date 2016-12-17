//
//  main.m
//  OCHacker
//
//  Created by Jone on 12/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EOCAutoDictionary.h"
#import "RuntimeClass.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        EOCAutoDictionary *dict = [EOCAutoDictionary new];
        [dict setString:@"string"];
//        NSLog(@"%@", dict.string);

    }
    return 0;
}

