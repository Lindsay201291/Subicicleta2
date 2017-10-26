//
//  FLDetailTabsView.m
//  iFlynax
//
//  Created by Alex on 12/11/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAdDetailsRootView.h"

#import "FLDetailsView.h"
#import "FLSellerInfoView.h"
#import "FLListingVideos.h"
#import "FLAdOnMapView.h"
#import "FLMessaging.h"
#import "CCActionSheet.h"
#import "FLReportAbuseVC.h"

@interface FLAdDetailsRootView () {
    FLSellerInfoView *_tabSellerInfo;
    FLDetailsView *_tabAdDetails;
}
@end

@implementation FLAdDetailsRootView

- (void)awakeFromNib {
    [super awakeFromNib];

	self.gaScreenName = FLLocalizedString(@"screen_listing_details");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.gaScreenName;

    if (_shortDetails != nil) {
        [self loadListingDetails];
    }
    else [FLDebug showAdaptedError:nil apiItem:kApiItemAdDetails];
}

- (void)loadListingDetails {
    [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];

    self.tabsControl.alpha = 0;
    self.pageViewController.view.alpha = 0;

    [flynaxAPIClient getApiItem:kApiItemAdDetails
                     parameters:@{@"lid": @(_shortDetails.lId)}
                     completion:^(NSDictionary *results, NSError *error) {
                         if (error == nil && [results isKindOfClass:NSDictionary.class]) {
                             [self configuteTabsWithData:results];
                         }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemAdDetails];
                     }];
}

- (void)configuteTabsWithData:(NSDictionary *)data {

    // configure listing details tab
    _tabAdDetails = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAdDetailsView];
    _tabAdDetails.shortInfo = _shortDetails;
    _tabAdDetails.entries   = [data[@"sections"] mutableCopy];
    _tabAdDetails.photos    = data[@"photos"];
    _tabAdDetails.comments  = data[@"comments"];
    _tabAdDetails.seoListingUrl = FLCleanString(data[@"seo_link"]);
    _tabAdDetails.allCommentsCount = FLTrueInt(data[@"comments_calc"]);
    
    [self addTabViewController:_tabAdDetails];

    // configure listing details tab
    _tabSellerInfo = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAdSellerInfoView];
    _tabSellerInfo.sellerInfo = data[@"sellerInfo"];
    [self addTabViewController:_tabSellerInfo];

    // configure video's tab
    if (data[@"videos"] != nil) {
        FLListingVideos *tabVideo = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAdVideosView];
        tabVideo.videos = data[@"videos"];
        [self addTabViewController:tabVideo];
    }

    // configure map tab
    if (_shortDetails.location != nil) {
        FLAdOnMapView *tabMap = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAdOnMapView];
        tabMap.location = _shortDetails.location;
        tabMap.abilityToBuildRoute = YES;
        [self addTabViewController:tabMap];
    }

    [self appendTabsAndDisplaySelected];
    [FLProgressHUD dismiss];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"accessory_details"]
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(moreActionsBtnDidTap:)];

    // simulate fadeIn effect
    [UIView animateWithDuration:.3f animations:^{
        self.pageViewController.view.alpha = 1;
        self.tabsControl.alpha = 1;
    }];
}

- (void)moreActionsBtnDidTap:(UIBarButtonItem *)button {
    CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:nil];

    if ([FLAccount loggedUser].userId != FLTrueInteger(_tabSellerInfo.sellerInfo[@"id"])) {
        [sheet addButtonWithTitle:FLLocalizedString(@"ad_details_sheetActions_contactSeller") block:^{
            if (IS_LOGIN) {
                FLMessaging *messaging = [_tabSellerInfo prepareContactOwnerMessaging];
                [self.navigationController pushViewController:messaging animated:YES];
            }
            else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"messaging_must_logged_in")];
        }];
    }

    [sheet addButtonWithTitle:FLLocalizedString(@"ad_details_sheetActions_share") block:^{
        [_tabAdDetails sheetActionsShareAdDidTap:button];
    }];

    BOOL adIsFavorite = [[FLFavorites sharedInstance] isFavoriteWithId:_tabAdDetails.shortInfo.lId];
    NSString *favCurrentTitleKey = F(@"ad_details_sheetActions_%@", adIsFavorite ? @"removeFromFavorites" : @"addToFavorites");
    [sheet addButtonWithTitle:FLLocalizedString(favCurrentTitleKey) block:^{
        [_tabAdDetails.detailsTableView.headerView.favoriteAdsButton dofakeTapAction];
    }];

    if ([FLConfig boolWithKey:@"reportBrokenListing_plugin"]) {
        [sheet addDestructiveButtonWithTitle:FLLocalizedString(@"reportAbuse_sheet_item") block:^{
            FLReportAbuseVC *reportAbuseVC = [[FLReportAbuseVC alloc] initWithNibName:@"FLReportAbuseVC" bundle:nil];
            reportAbuseVC.lId = _tabAdDetails.shortInfo.lId;
            FLNavigationController *reportAbuseNC = reportAbuseVC.flNavigationController;
            [self.navigationController presentViewController:reportAbuseNC animated:YES completion:nil];
        }];
    }

    [sheet addCancelButtonWithTitle:FLLocalizedString(@"button_cancel")];
    [sheet showFromBarButtonItem:button];
}

@end
