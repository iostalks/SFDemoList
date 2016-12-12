//
//  EOCAutoDictionary.m
//  OCHacker
//
//  Created by Jone on 12/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//

#import "EOCAutoDictionary.h"
#import <objc/runtime.h>

#define kDefaultCondition 1
#define kForwardingCondition 1
#define kForwardInvocationCondition 1
#define kResolve 1

// 备援接受者 for forwardingTargetForSelector
@interface EOCPrepareRecevier : NSObject

@end

@implementation EOCPrepareRecevier {
    NSString *_string;
}

- (NSString *)string {
    return _string;
}

- (void)setString:(NSString *)string {
    _string = string;
}

@end

@interface EOCAutoDictionary()

@property(nonatomic, strong) NSMutableDictionary *backingStore;

@end

id autoDictionaryGetter(id self, SEL _cmd);
void autoDictionarySetter(id self, SEL _cmd, id value);

@implementation EOCAutoDictionary {
    NSString *_string; // Because dynamic killed property setter and getter method
                       // so declare a ivar for string property.
                       // Used for 默认实现.
}

@dynamic string, number, date, opaqueObject;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backingStore = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - 默认实现

#if 0
- (NSString *)string {
    return _string;
}

- (void)setString:(NSString *)string {
    _string = string;
}

// ...
#endif

#pragma mark - 动态解析方法

#if 0
// If return NO this method invoke twice. Why?
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString hasPrefix:@"set"]) {
        BOOL success = class_addMethod(self, sel, (IMP)autoDictionarySetter, "v@:@"); // Type Encoding(void,id,selector,id) https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        return success;
    } else {
        BOOL success = class_addMethod(self, sel, (IMP)autoDictionaryGetter, "@@:"); // Type Encoding(id, id, selector)
        return success;
    }
    return NO;
}

id autoDictionaryGetter(id self, SEL _cmd) {
    EOCAutoDictionary *typeSelf = (EOCAutoDictionary *)self;
    NSMutableDictionary *backingStore = typeSelf.backingStore;
    
    NSString *key = NSStringFromSelector(_cmd);
    return [backingStore objectForKey:key];
}

void autoDictionarySetter(id self, SEL _cmd, id value) {
    EOCAutoDictionary *typeSelf = (EOCAutoDictionary *)self;
    NSMutableDictionary *backingStore = typeSelf.backingStore;
    
    NSString *selectorString = NSStringFromSelector(_cmd);
    NSMutableString *key = [selectorString mutableCopy];
    
    [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    NSString *lowercaseFirstChar = [[key substringToIndex:1] lowercaseString];
    [key replaceCharactersInRange:(NSRange){0,1} withString:lowercaseFirstChar];
    
    if (value) {
        [backingStore setObject:value forKey:key];
    } else {
        [backingStore removeObjectForKey:key];
    }
}

#endif

#pragma mark - 备援接受者

- (id)forwardingTargetForSelector:(SEL)aSelector {
    EOCPrepareRecevier *prepareReceiver = [EOCPrepareRecevier new];
    if ([prepareReceiver respondsToSelector:aSelector]) { // 不公开 EOCPrepareRecevier 的方法这个条件仍然能成立
        return prepareReceiver;
    }
    return nil;
}


#pragma mark - 完整的消息转发

// 这个方法怎么都不会调用？？
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
}


@end
