//
//  FLDetailsView.h
//  iFlynax
//
//  Created by Alex on 4/29/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "FLDetailsTableViews.h"

@interface FLDetailsView : FLViewController
@property (strong, nonatomic) FLAdShortDetailsModel *shortInfo;
@property (strong, nonatomic) NSMutableArray *entries;
@property (copy, nonatomic) NSArray *photos;
@property (copy, nonatomic) NSArray *comments;
@property (nonatomic) int allCommentsCount;

@property (copy, nonatomic) NSString *seoListingUrl;
@property (weak, nonatomic) IBOutlet FLDetailsTableView *detailsTableView;

- (void)sheetActionsShareAdDidTap:(id)sender;
@end
