//
//  NSObject+YSObserver.h
//  YSObjectObserver
//
//  Created by oubaiquan on 2019/4/10.
//  Copyright © 2019 Youngsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 一个轻量级的以block回调形式来通知观察对象属性变化的KVO扩展。
 被观察对象添加观察者后，无论是被观察对象还是观察者对象销毁时都会自动取消这种观察与被观察关系。
 一个被观察者可以添加多个观察者block进行不同的处理。
 */
@interface NSObject (YSObserver)


/**
 对当前对象的keyPath添加观察者

 @param observer 观察者对象，这个参数只用于区分不同的观察者，以及支持多个观察者用。
 @param keyPath 观察的属性路径
 @param block 当被观察的keyPath的值发生变化时会调用此block。block中的newVal和oldVal分别代表被观察的属性的新值和老值。
 */
-(void)ys_addObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath withBlock:(void(^)(id newVal, id oldVal))block;


/**
 对当前对象的keyPath添加观察者，并只执行一次观察，调用后会取消观察

 @param observer 观察者对象，这个参数只用于区分不同的观察者，以及支持多个观察者用。
 @param keyPath 观察的属性路径
 @param block 当被观察的keyPath的值发生变化时会调用此block。block中的newObj和oldObj分别代表被观察的属性的新值和老值。
 */
-(void)ys_addObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath withOnceBlock:(void(^)(id newVal, id oldVal))block;


/**
 删除观察者

 @param observer 被删除的观察者
 @param keyPath 被删除的keyPath
 */
-(void)ys_removeObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath;


/**
 删除所有keyPath对应的观察者

 @param keyPath 要删除观察的keyPath
 */
-(void)ys_removeAllObserverForKeyPath:(NSString *)keyPath;


/**
 判断某个观察者是否存在

 @param observer 观察者对象
 @param keyPath 观察的keyPath
 @return 如果存在则返回YES,否则返回NO
 */
-(BOOL)ys_hasObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
