//
//  FLRecentlyAdsRootView.m
//  iFlynax
//
//  Created by Alex on 12/11/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLRecentlyAdsRootView.h"
#import "FLRecentlyView.h"

@implementation FLRecentlyAdsRootView

- (void)awakeFromNib {
    [super awakeFromNib];

	self.gaScreenName = FLLocalizedString(@"screen_recently_view");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.gaScreenName;

    [[FLListingTypes getList] enumerateObjectsUsingBlock:^(NSDictionary *type, NSUInteger idx, BOOL *stop) {
        FLRecentlyView *recentlyAdsController;
        FLListingTypeModel *listingType = [FLListingTypeModel fromDictionary:type];

        recentlyAdsController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardRecentlyAdsView];
        recentlyAdsController.lType = listingType;

        [self.pages addObject:recentlyAdsController];
        [self.tabsControlTitles addObject:[listingType.name uppercaseString]];
    }];
    [self appendTabsAndDisplaySelected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
	[self.frostedViewController presentMenuViewController];
}

@end
