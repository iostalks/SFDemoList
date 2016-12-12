//
//  EOCAutoDictionary.h
//  OCHacker
//
//  Created by Jone on 12/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EOCAutoDictionary : NSObject

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) id opaqueObject;

@end
