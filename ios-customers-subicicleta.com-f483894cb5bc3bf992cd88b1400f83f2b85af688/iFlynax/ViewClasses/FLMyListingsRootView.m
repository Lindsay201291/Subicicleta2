//
//  FLMyListingsRootView.m
//  iFlynax
//
//  Created by Alex on 12/11/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLMyListingsRootView.h"
#import "FLMyListingsView.h"

@implementation FLMyListingsRootView

- (void)awakeFromNib {
    [super awakeFromNib];

	self.gaScreenName = FLLocalizedString(@"screen_myListings_view");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.gaScreenName;

    [[FLListingTypes getList] enumerateObjectsUsingBlock:^(NSDictionary *type, NSUInteger idx, BOOL *stop) {
        FLMyListingsView *myListingsController;
        FLListingTypeModel *listingType = [FLListingTypeModel fromDictionary:type];

        myListingsController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardMyListingsView];
        myListingsController.lType = listingType;

        [self.pages addObject:myListingsController];
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
