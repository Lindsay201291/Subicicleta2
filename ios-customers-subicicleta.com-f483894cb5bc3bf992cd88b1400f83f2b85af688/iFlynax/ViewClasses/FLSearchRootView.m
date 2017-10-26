//
//  FLSearchRootView.m
//  iFlynax
//
//  Created by Alex on 10/27/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLSearchView.h"
#import "FLSearchRootView.h"
#import "REFrostedViewController.h"

@implementation FLSearchRootView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_search");

    for (NSDictionary *ltypeDict in [FLListingTypes getList]) {
        FLListingTypeModel *ltypeModel = [FLListingTypeModel fromDictionary:ltypeDict];

        if (ltypeModel.search && _forms[ltypeModel.key] != nil) {
            FLSearchView *searchVC =
            [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSearchView];
            searchVC.fields      = _forms[ltypeModel.key] ?: @[];
            searchVC.title       = ltypeModel.name;
            searchVC.listingType = ltypeModel;

            [self addTabViewController:searchVC];
        }
    }
    [self appendTabsAndDisplaySelected];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
