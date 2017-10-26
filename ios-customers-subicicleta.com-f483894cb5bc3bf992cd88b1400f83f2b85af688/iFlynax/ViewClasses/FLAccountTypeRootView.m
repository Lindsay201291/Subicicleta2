//
//  FLAccountTypeRootView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAccountTypeRootView.h"
#import "REFrostedViewController.h"
#import "FLAccountTypeListViewController.h"
#import "FLAccountTypeSearchViewController.h"

@implementation FLAccountTypeRootView

- (void)viewDidLoad {
    [super viewDidLoad];

    FLAccountTypeListViewController *listViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountTypeListViewController];
    listViewController.typeModel = self.typeModel;
    [self addTabViewController:listViewController];

    FLAccountTypeSearchViewController *searchViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountTypeSearchViewController];
    searchViewController.typeModel = self.typeModel;
    [self addTabViewController:searchViewController];

    [self appendTabsAndDisplaySelected];
}

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
