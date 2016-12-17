//
//  RuntimeClass.m
//  OCHacker
//
//  Created by Jone on 14/12/2016.
//  Copyright © 2016 Jone. All rights reserved.
//
// http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/

#import "RuntimeClass.h"
#import <objc/runtime.h>

id objc_msgSend_(id self, SEL op, ...);

/// SEL
struct objc_selector_ {
    // objc_selector 的实现是不透明的。
};
typedef struct objc_selector_ *SEL;
// @selector(setString:);
// sel_registerName("setString:");

/// id
struct objc_object_ {
    Class isa OBJC_ISA_AVAILABILITY;
};
typedef struct objc_object_ *id;

/// Class
struct objc_class_ {
    Class isa OBJC_ISA_AVAILABILITY;
    
#if !__OBJC2__
    Class super_class;
    const char *name;
    long version;
    long info;
    long instance_size;
    struct objc_ivar_list *ivars;
    struct objc_method_list **methodLists;
    struct objc_cache *cache;
    struct objc_protocol_list *protocols;
#endif
};
typedef struct objc_class_ *Class;

//isa指针不总是指向实例对象所属的类，不能依靠它来确定类型，
//而是应该用class方法来确定实例对象的类。
//因为KVO的实现机理就是将被观察对象的isa指针指向一个中间类而不是真实的类，
//这是一种叫做 isa-swizzling 的技术

struct objc_ivar_list {
    int ivar_count;
#ifdef __LP64__
    int  space;
#endif
//    struct objc_ivar ivar_list[1]; // error
};

struct objc_method_list {
    struct objc_method_list *obsolete;
    int method_count;
#ifdef __LP64__
    int space;
#endif
//    struct objc_method method_list[1];
};

// isa: 实例 -> 类(类对象) -> 元类 -> 根元类 <->
// 根元类的 superclass 为根类(NSObject)
// 根元类的 isa 指针指向自己

// superclass: 子类 -> 父类 -> 根类（NSObject） -> nil
// 根类(NSObject)的 superclass 为 nil
// 根类的 isa 指针指向根元类

/// Method
struct objc_method {
    SEL method_name; // 方法名类型，相同名字的方法即使在不同的类中
                     // 它们的方法选择器也相同。
    char *method_types;
    IMP method_imp;
};
typedef struct objc_method *Method;

/// Ivar
struct objc_ivar {
    char *ivar_name;
    char *ivar_type;
    int ivar_offset;
#ifdef __LP64__
    int space;
#endif
};

/// IMP
typedef id (*IMP_) (id, SEL, ...);


/// Cache
typedef struct obj_cache *Cache;

struct obj_cache {
    unsigned int mask;
    unsigned int occupied;
    Method bucket[1];
};

/// Property
typedef struct objc_property *Property;
typedef struct objc_property *objc_property_t;

/// 获取方法的 IMP
//void (*setter)(id , SEL, BOOL);
//setter = (void (*)(id , SEL, BOOL))[target methodForSelector:@selector(SetA:)];
//setter(target, @selector(SetA:), YES);

// class 方法只是返回当前类的类别

@implementation RuntimeClass {
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self methodForSelector:@selector(init)];
    }
    return self;
}

// 查找某个实例在类中的名字
- (NSString *)nameWithInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key = nil;
    Ivar *ivars = class_copyIvarList([self class], &numIvars);
    for (int i = 0; i < numIvars; ++i) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType = [NSString stringWithUTF8String:type];
        NSLog(@"type = %@", stringType);
        if (![stringType hasPrefix:@"@"]) { // 对象类型
            continue;
        }
        id objectIvar = object_getIvar(self, thisIvar);
        if (objectIvar == instance) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

@end
