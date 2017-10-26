//
//  FLSellerAdsViewController.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLSellerAdsViewController.h"

@implementation FLSellerAdsViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = FLLocalizedString(@"screen_seller_ads");
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.apiCmd  = kApiItemRequests_listingsByAccount;
    [self addApiParameter:@(_sellerId) forKey:@"aid"];
    
    if (_loadAds) {
        [self.entries addObjectsFromArray:_loadAds[@"listings"]];
        self.itemsTotal = [_loadAds[@"calc"] intValue];
        self.currentStack++;
        [self fadeTableViewIn];
    }

    self.blankSlate.title   = FLLocalizedString(@"blankSlate_sellerAds_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_sellerAds_message");
}

@end
