//
//  FLTestTableVC.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLExtendedTableViewController.h"
#import "FLAdsViewCell.h"

@interface FLAdsTableViewController : FLExtendedTableViewController

- (void)fillUpAdsCell:(FLListingViewCell *)cell ForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)pushDetailsForIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)heightForCell:(FLListingViewCell *)cell;

@end
