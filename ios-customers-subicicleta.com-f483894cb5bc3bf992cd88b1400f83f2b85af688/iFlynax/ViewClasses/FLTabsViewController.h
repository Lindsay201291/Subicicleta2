//
//  FLTabsViewController.h
//  iFlynax
//
//  Created by Alex on 12/10/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "HMSegmentedControl.h"

static NSString * const kTabsDataIndexKey  = @"dataIndex";
static NSString * const kTabsIdentifierKey = @"identifier";

typedef void (^FLTabsConfigureBlock)(UIViewController *controller, NSUInteger idx, NSString *identifier);

@interface FLTabsViewController : FLViewController
@property (weak, nonatomic) IBOutlet HMSegmentedControl *tabsControl;
@property (weak, nonatomic) IBOutlet UIView             *contentView;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray       *tabsControlTitles;
@property (strong, nonatomic) NSString             *gaScreenName;
@property (strong, nonatomic) NSMutableArray       *pages;

@property (nonatomic, assign) id userInfo;

- (UIViewController *)selectedController;
- (void)reverceTabsIfNecessary;

- (void)setupPagesFromStoryboardWithIdentifiers:(NSArray *)identifiers;
- (void)setupPagesFromStoryboardWithIdentifiers:(NSArray *)identifiers
									  configure:(FLTabsConfigureBlock)configureBlock;

- (void)addTabViewController:(UIViewController *)controller;
- (void)addTabViewController:(UIViewController *)controller withTitle:(NSString *)title;

- (void)appendTabsAndDisplaySelected;
- (void)appendTabsAndDisplaySelected:(NSInteger)index;
@end
