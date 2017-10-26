//
//  FLAccountDetailsRootViewController.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAccountDetailsRootViewController.h"
#import "FLSellerAdsViewController.h"
#import "FLSellerInfoView.h"
#import "FLAdOnMapView.h"

@implementation FLAccountDetailsRootViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.gaScreenName = @"Account Details";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:FLLocalizedString(@"screen_account_details")];

    if (_sellerId) {
        [self loadAccountDetails];
    }
    else [FLDebug showAdaptedError:nil apiItem:kApiItemSellerDetails];

    if (self.presentingViewController != nil) {
        self.navigationItem.leftBarButtonItem = ({
            UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                       initWithTitle:FLLocalizedString(@"button_cancel")
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(dismissController)];
            button;
        });
    }
}

- (void)loadAccountDetails {
    [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];

    [flynaxAPIClient getApiItem:kApiItemSellerDetails
                     parameters:@{@"aid": @(_sellerId)}
                     completion:^(NSDictionary *results, NSError *error) {
                         if (error == nil && [results isKindOfClass:NSDictionary.class]) {
                             [self configuteTabsWithData:results];
                         }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemSellerDetails];
                     }];
}

- (void)configuteTabsWithData:(NSDictionary *)data {

    // configure listing details tab
    FLSellerInfoView *tabSellerInfo = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAdSellerInfoView];
    tabSellerInfo.sellerInfo = data[@"sellerInfo"];
    [self addTabViewController:tabSellerInfo];

    // configure seller ads tab
    FLSellerAdsViewController *tabSellerAds = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSellerAdsViewController];
    tabSellerAds.sellerId = _sellerId;
    tabSellerAds.loadAds = data[@"sellerAds"];
    [self addTabViewController:tabSellerAds];

    // configure map tab
    if (data[@"location"] != nil) {
        FLAdOnMapView *tabMap = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAdOnMapView];
        tabMap.location = data[@"location"];
        tabMap.abilityToBuildRoute = NO;
        [self addTabViewController:tabMap];
    }

    if (_selectedTab == FLAccountDetailsSelectedTabSellerAds)
        [self appendTabsAndDisplaySelected:(IS_RTL ? 0 : FLAccountDetailsSelectedTabSellerAds)];
    else
        [self appendTabsAndDisplaySelected];

    [FLProgressHUD dismiss];
}

#pragma mark - Navigation

- (void)dismissController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
