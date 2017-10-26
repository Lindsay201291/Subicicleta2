//
//  FLTypedAdsTableViewController.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTypedAdsTableViewController.h"

@interface FLTypedAdsTableViewController ()

@end

@implementation FLTypedAdsTableViewController

- (void)viewDidLoad {
    
    if (_lType == nil && [FLListingTypes typesCount] == 1) {
        _lType = [[FLListingTypes sharedInstance] mainType];
    }
    
    [self addApiParameter:_lType.key forKey:@"type"];
    
    [super viewDidLoad];
}

@end
