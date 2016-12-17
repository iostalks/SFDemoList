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
#import "Saker.h"

@interface EOCAutoDictionary()

@property(nonatomic, strong) NSMutableDictionary *backingStore;

@end

id autoDictionaryGetter(id self, SEL _cmd);
void autoDictionarySetter(id self, SEL _cmd, id value);

@implementation EOCAutoDictionary {
    NSString *_string; // Because dynamic killed property setter and getter method
                       // so declare a ivar for string property.
                       // Used for Defult Implementation
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

#pragma mark - Default Implementation

#if 1
- (NSString *)string {
    return _string;
}

- (void)setString:(NSString *)string {
    _string = string;
}

// ...
#endif

#pragma mark - Resolve

//+ (BOOL)resolveClassMethod:(SEL)sel {
//    return [class_getSuperclass(self) resolveClassMethod:sel];
//}

#if 0
// If return NO this method invoke twice. Why?
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selectorString = NSStringFromSelector(sel);
    if ([selectorString hasPrefix:@"set"]) {
        BOOL success = class_addMethod([self class], sel, (IMP)autoDictionarySetter, "v@:@"); // Type Encoding(void,id,selector,id) https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        return success;
    } else {
        BOOL success = class_addMethod([self class], sel, (IMP)autoDictionaryGetter, "@@:"); // Type Encoding(id, id, selector)
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
    Saker *saker = [Saker new];
    if ([saker respondsToSelector:aSelector]) { // 不公开 EOCPrepareRecevier 的方法这个条件仍然能成立
        return saker;
    }
    return [super forwardingTargetForSelector:aSelector];
}


#pragma mark - 完整的消息转发
// 该方式的实现与备援接受者方式基本等效。
// 比较实用的用法是：在触发消息前，先以某种方式改变消息内容，
// 比如追加另外个参数或者换选择子，等等。
#if 0
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    Saker *saker = [Saker new];
    if ([saker respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:saker];
    } else {
        [super forwardInvocation: anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}
#endif

#pragma mark - Method Swizzling

#if 1
+ (void)load { // load 方法默认从父类调用
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [self class];
        
        SEL originalSelector = @selector(viewWillApper:);
        SEL swizzledSelector = @selector(xxx_viewWillApper:);
        
        Method orignMethod = class_getClassMethod(aClass, originalSelector);
        Method swizzledMethod = class_getClassMethod(aClass, swizzledSelector);
        
        // 将 swizzledMethod 作为 originalSeletor 的实现
        BOOL didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            // 替换 swizzledSelector 的实现为 originMethod
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(orignMethod), method_getTypeEncoding(orignMethod));
        } else {
            method_exchangeImplementations(orignMethod, swizzledMethod);
        }
    });
}

+ (Class)class {
    return self;
}

- (Class)class {
    return object_getClass(self); // Class invoke return metaclass.
}

#endif

@end
