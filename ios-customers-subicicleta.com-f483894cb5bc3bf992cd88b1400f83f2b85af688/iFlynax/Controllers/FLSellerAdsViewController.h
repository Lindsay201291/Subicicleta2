//
//  FLSellerAdsViewController.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAdsTableViewController.h"

@interface FLSellerAdsViewController : FLAdsTableViewController

@property (nonatomic, assign) NSInteger sellerId;
@property (nonatomic, copy) NSDictionary *loadAds;

@end
