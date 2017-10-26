//
//  FLAccountDetailsRootViewController.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTabsViewController.h"

typedef NS_ENUM(NSInteger, FLAccountDetailsSelectedTab) {
    FLAccountDetailsSelectedTabSellerInfo = 0,
    FLAccountDetailsSelectedTabSellerAds  = 1,
};

@interface FLAccountDetailsRootViewController : FLTabsViewController
@property (nonatomic, assign) FLAccountDetailsSelectedTab selectedTab;
@property (nonatomic, assign) NSInteger sellerId;
@end
