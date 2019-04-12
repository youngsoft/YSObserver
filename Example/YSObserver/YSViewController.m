//
//  YSViewController.m
//  YSObserver
//
//  Created by youngsoft on 04/12/2019.
//  Copyright (c) 2019 youngsoft. All rights reserved.
//

#import "YSViewController.h"
#import "NSObject+YSObserver.h"


@interface YSViewController ()

@end

@implementation YSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view ys_addObserver:self forKeyPath:@"frame" withBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        NSLog(@"self.view's frame is from %@ to %@", oldVal, newVal);
        
    }];
    
    
    [self.view ys_addObserver:self forKeyPath:@"frame" withOnceBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        NSLog(@"once: self.view's frame is from %@ to %@", oldVal, newVal);
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
