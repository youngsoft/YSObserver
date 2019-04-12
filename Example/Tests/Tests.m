//
//  YSObserverTests.m
//  YSObserverTests
//
//  Created by youngsoft on 04/12/2019.
//  Copyright (c) 2019 youngsoft. All rights reserved.
//

@import XCTest;
#import "NSObject+YSObserver.h"


@interface OBservable:NSObject

@property(nonatomic, strong) NSString *name;

@property(nonatomic, assign) NSInteger age;

@end

@implementation OBservable


@end

@interface OBserver:NSObject

@end

@implementation OBserver


@end


@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    OBservable *observable = [OBservable new];
    
    observable.name = @"a";
    
    [observable ys_addObserver:self forKeyPath:@"name" withBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        XCTAssert([newVal isEqualToString:@"b"] ||[newVal isEqualToString:@"c"] );
    }];
    
    [observable ys_addObserver:self forKeyPath:@"name" withOnceBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        XCTAssert([newVal isEqualToString:@"b"]);
    }];
    
    
    OBserver  *observer1 = [OBserver new];
    
    [observable ys_addObserver:observer1 forKeyPath:@"age" withBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        XCTAssert(1);
        
    }];
    
    observer1 = nil;
    
    
    OBserver *observer2 = [OBserver new];
    
    [observable ys_addObserver:observer2 forKeyPath:@"age" withBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        XCTAssert([newVal integerValue] == 20);
    }];
    
    observable.age = 20;
    
    observable.name = @"b";
    
    observable.name = @"c";
    
    [observable ys_removeObserver:observer2 forKeyPath:@"age"];
    
    OBservable *observable2 = [OBservable new];
    
    [observable2 ys_addObserver:self forKeyPath:@"name" withBlock:^(id  _Nonnull newVal, id  _Nonnull oldVal) {
        
        XCTAssert([newVal isEqualToString:@"d"]);

    }];
    
    observable2.name = @"d";
    
    XCTAssertTrue([observable2 ys_hasObserver:self forKeyPath:@"name"]);
    
    [observable2 ys_removeAllObserverForKeyPath:@"name" ];
    
    XCTAssertFalse([observable2 ys_hasObserver:self forKeyPath:@"name"]);

    
   // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end

