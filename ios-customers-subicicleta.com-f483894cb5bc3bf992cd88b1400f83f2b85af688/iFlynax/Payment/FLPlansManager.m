//
//  FLPlansManager.m
//  iFlynax
//
//  Created by Alex on 11/3/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLPlansManager.h"

@implementation FLPlansManager

+ (instancetype)sharedManager {
    static FLPlansManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        [_sharedManager initWithDefaults];
    });
    return _sharedManager;
}

+ (void)restoreToDefaults {
    [[FLPlansManager sharedManager] initWithDefaults];
}

- (void)initWithDefaults {
    _plans        = [NSMutableArray array];
    _planButtons  = [NSMutableArray array];
    _skProducts   = [NSMutableDictionary dictionary];

    _selectedPlan = nil;
    _currentPlan  = nil;
}

- (BOOL)planWasChanged {
    return _currentPlan != _selectedPlan;
}

@end
