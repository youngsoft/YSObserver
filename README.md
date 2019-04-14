# YSObserver

[![CI Status](https://img.shields.io/travis/youngsoft/YSObserver.svg?style=flat)](https://travis-ci.org/youngsoft/YSObserver)
[![Version](https://img.shields.io/cocoapods/v/YSObserver.svg?style=flat)](https://cocoapods.org/pods/YSObserver)
[![License](https://img.shields.io/cocoapods/l/YSObserver.svg?style=flat)](https://cocoapods.org/pods/YSObserver)
[![Platform](https://img.shields.io/cocoapods/p/YSObserver.svg?style=flat)](https://cocoapods.org/pods/YSObserver)

一个轻量级的通过Block执行通知回调的对象KVO扩展，整个库一共200行代码。

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How to use


* Normally KVO:

```

@interface Observer:NSObject

@end

@implementation Observer

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"frame"]){
		NSLog(@"the frame=%@", change[NSKeyValueChangeNewKey]);
    }
}

@end


UIView *view = [UIView new];
Observer *observer = [Observer new];

[view addObserver:observer forKeyPath:@"frame"  options:NSKeyValueObservingOptionNew  context:NULL];
view.frame = CGRectZero;

```

* YSObserver 

```

UIView *view = [UIView new];
[view ys_addObserver:anyObject forKeyPath:@"frame" withBlock:^(id newVal, id OldVal){

	NSLog(@"the frame=%@", newVal);
}];

```



## Requirements

## Installation

YSObserver is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YSObserver'
```

## Author

youngsoft, obq0387_cn@sina.com

## License

YSObserver is available under the MIT license. See the LICENSE file for more info.
