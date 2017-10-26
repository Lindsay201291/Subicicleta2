//
//  FLTestTableVC.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAdsTableViewController.h"
#import "FLAdsViewCell.h"

@implementation FLAdsTableViewController

- (void)viewDidLoad {
    
    UINib *cellNib = [UINib nibWithNibName:kNibNameLShortFormViewCell bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kStoryBoardAdsCellIdentifier];
    
    [super viewDidLoad];
    
    self.initStack    = 1;
    self.currentStack = 1;
    
    self.targetItemName = FLLocalizedString(@"inf_scroll_target_ads");
}

- (void)handleSucceedRequest:(id)results {
    NSArray *listings = results[@"listings"];
    self.itemsTotal = [results[@"calc"] intValue];
    
    [self.entries addObjectsFromArray:listings];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLAdsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardAdsCellIdentifier];
    
    [self fillUpAdsCell:cell ForRowAtIndexPath:indexPath];
    [cell.favoriteButton setIndexPath:indexPath];

    return cell;
}

- (void)fillUpAdsCell:(FLListingViewCell *)cell ForRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell fillWithInfoDictionary:[self itemInfoForIndexPath:indexPath]];
}

- (NSDictionary *)itemInfoForIndexPath:(NSIndexPath *)indexPath {
    return self.headers.count ? self.entries[indexPath.section][indexPath.row] : self.entries[indexPath.row];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static FLAdsViewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardAdsCellIdentifier];
    });
    
    [self fillUpAdsCell:cell ForRowAtIndexPath:indexPath];
    
    return [self heightForCell:cell];
}

- (CGFloat)heightForCell:(FLListingViewCell *)cell {
    cell.bounds = CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, cell.bounds.size.height);
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
   
    return size.height + 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        [self pushDetailsForIndexPath:indexPath];
    }
}

- (void)pushDetailsForIndexPath:(NSIndexPath *)indexPath {
    FLAdDetailsRootView *listingDetails = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardadDetailsRootView];
    NSDictionary *itemInfo              = [self itemInfoForIndexPath:indexPath];
    listingDetails.shortDetails         = [FLAdShortDetailsModel fromDictionary:itemInfo];
    
    [self.navigationController pushViewController:listingDetails animated:YES];
}

@end
