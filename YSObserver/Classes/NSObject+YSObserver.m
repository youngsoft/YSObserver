//
//  NSObject+YSObserver.m
//  YSObjectObserver
//
//  Created by oubaiquan on 2019/4/10.
//  Copyright © 2019 Youngsoft. All rights reserved.
//

#import "NSObject+YSObserver.h"
#import <objc/runtime.h>

#define YSOBSERVER_KEY "ys_observerkey"

static void _ys_addObserver(NSObject *observable, NSObject *observer, NSString *keyPath, BOOL once, void(^block)(id, id) );
static void _ys_removeObserver(NSObject *observable, NSObject *observer, NSString *keyPath);
static void _ys_removeAllObserver(NSObject *observable, NSString *keyPath);
static void _ys_observe(NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context);
static BOOL _ys_hasObserver(NSObject *observable, NSObject *observer, NSString *keyPath);
//接口实现部分
@implementation NSObject (YSObserver)

-(void)ys_addObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath withBlock:(void(^)(id, id))block
{
    _ys_addObserver(self, observer, keyPath, NO, block);
}

-(void)ys_addObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath withOnceBlock:(void(^)(id, id))block
{
    _ys_addObserver(self, observer, keyPath, YES, block);
}

-(void)ys_removeObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath
{
    _ys_removeObserver(self, observer, keyPath);
}

-(void)ys_removeAllObserverForKeyPath:(NSString *)keyPath
{
    _ys_removeAllObserver(self, keyPath);
}

-(BOOL)ys_hasObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    return _ys_hasObserver(self, observer, keyPath);
}


@end


//内部实现部分
///////////////////////////////////////////////////////////////////////////////////
@interface _YSObserverEngine : NSObject

+(instancetype)shared;

@end

@implementation _YSObserverEngine

+(instancetype)shared
{
    static _YSObserverEngine *g_observerEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_observerEngine = [_YSObserverEngine new];
    });
    return g_observerEngine;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    _ys_observe(keyPath, object, change, context);
}

@end

///////////////////////////////////////////////////////////////////////////////////
@interface _YSObserverBlock:NSObject

@property(nonatomic, weak) NSObject *observer;
@property(nonatomic, copy) void (^block)(id, id);
@property(nonatomic, assign) BOOL once;

@end

@implementation _YSObserverBlock

@end

///////////////////////////////////////////////////////////////////////////////////
@interface _YSKeyPathContext:NSObject

@property(nonatomic, strong) NSString *keyPath;
@property(nonatomic, assign) NSObject *observable;
@property(nonatomic, strong) NSMutableArray<_YSObserverBlock *> *observerBlocks;

@end

@implementation _YSKeyPathContext

-(void)dealloc
{
    if (_observable != nil){
        [_observable removeObserver:[_YSObserverEngine shared] forKeyPath:_keyPath context:(__bridge void * _Nullable)(self)];
        _observable = nil;
    }
}

@end

///////////////////////////////////////////////////////////////////////////////////
static void _ys_addObserver(NSObject *observable, NSObject *observer, NSString *keyPath, BOOL once, void(^block)(id, id) )
{
    _YSKeyPathContext *keyPathContext = nil;
    
    NSMutableDictionary *dict = objc_getAssociatedObject(observable, YSOBSERVER_KEY);
    if (dict == nil){
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(observable, YSOBSERVER_KEY, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else
        keyPathContext = dict[keyPath];
    
    if (keyPathContext == nil){
        keyPathContext = [_YSKeyPathContext new];
        keyPathContext.keyPath = keyPath;
        keyPathContext.observable = observable;
        keyPathContext.observerBlocks = [NSMutableArray new];
        dict[keyPath] = keyPathContext;
        //这里不增加引用计数的原因是，因为在被观察者销毁时，blockContext会自动销毁，而且一定是在发送KVO消息以后再销毁，所以不用担心对象生命周期的问题。
        [observable addObserver:[_YSObserverEngine shared] forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void * _Nullable)(keyPathContext)];
    }
    
    _YSObserverBlock *observerBlock = [_YSObserverBlock new];
    observerBlock.observer = observer;
    observerBlock.block = block;
    observerBlock.once = once;
    [keyPathContext.observerBlocks addObject:observerBlock];
   
}

static void _ys_removeObserverIfNeed(NSMutableDictionary *dict, _YSKeyPathContext *keyPathContext, NSObject *observable)
{
    if (keyPathContext.observerBlocks.count == 0){
        keyPathContext.observable = nil;
        [observable removeObserver:[_YSObserverEngine shared] forKeyPath:keyPathContext.keyPath context:(__bridge void * _Nullable)(keyPathContext)];
        [dict removeObjectForKey:keyPathContext.keyPath];
        
        if (dict.count == 0)
            objc_setAssociatedObject(observable, YSOBSERVER_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static void _ys_removeObserver(NSObject *observable, NSObject *observer, NSString *keyPath)
{
    NSMutableDictionary *dict = objc_getAssociatedObject(observable, YSOBSERVER_KEY);
    if (dict != nil){
        _YSKeyPathContext *keyPathContext = dict[keyPath];
        if (keyPathContext != nil){
            int count = (int)keyPathContext.observerBlocks.count;
            for (int i = count - 1; i >= 0; i--){
                _YSObserverBlock *observerBlock = keyPathContext.observerBlocks[i];
                if (observerBlock.observer == observer || observerBlock.observer == nil)
                    [keyPathContext.observerBlocks removeObjectAtIndex:i];
            }
            _ys_removeObserverIfNeed(dict, keyPathContext, observable);
        }
    }
}

static void _ys_removeAllObserver(NSObject *observable, NSString *keyPath)
{
    NSMutableDictionary *dict = objc_getAssociatedObject(observable, YSOBSERVER_KEY);
    if (dict != nil){
        _YSKeyPathContext *keyPathContext = dict[keyPath];
        if (keyPathContext != nil){
            [keyPathContext.observerBlocks removeAllObjects];
            _ys_removeObserverIfNeed(dict, keyPathContext, observable);
        }
    }
 }

static void _ys_observe(NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context)
{
    _YSKeyPathContext *keyPathContext = (__bridge _YSKeyPathContext *)(context);
    
    id newVal = change[NSKeyValueChangeNewKey];
    id oldVal = change[NSKeyValueChangeOldKey];
    
    int count = (int)keyPathContext.observerBlocks.count;
    for (int i = count - 1; i >= 0; i--){
        _YSObserverBlock *observerBlock = keyPathContext.observerBlocks[i];
        if (observerBlock.observer != nil){
            if (observerBlock.block != nil)
                observerBlock.block(newVal, oldVal);
            if (observerBlock.once)
                [keyPathContext.observerBlocks removeObjectAtIndex:i];
        }
        else
            [keyPathContext.observerBlocks removeObjectAtIndex:i];
    }
}

static BOOL _ys_hasObserver(NSObject *observable, NSObject *observer, NSString *keyPath)
{
    NSMutableDictionary *dict = objc_getAssociatedObject(observable, YSOBSERVER_KEY);
    if (dict != nil){
        _YSKeyPathContext *keyPathContext = dict[keyPath];
        if (keyPathContext != nil){
            for (_YSObserverBlock *observerBlock in keyPathContext.observerBlocks){
                if (observerBlock.observer == observer)
                    return YES;
            }
        }
    }
    
    return NO;
}
