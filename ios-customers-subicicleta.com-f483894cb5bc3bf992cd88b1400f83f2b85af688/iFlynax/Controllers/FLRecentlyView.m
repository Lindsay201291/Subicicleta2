//
//  FLRecentlyView.m
//  iFlynax
//
//  Created by Alex on 10/28/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLRecentlyView.h"
#import "FLTableSection.h"

static NSString * const kRecentlyAdsHeaderIdentifier = @"detailsHeaderIdentifier";

@implementation FLRecentlyView

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = FLLocalizedString(@"screen_recently_view");
    
    self.apiItem = kApiItemRecentlyAds;
    
    self.blankSlate.title = FLLocalizedString(@"blankSlate_recentlyAds_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_recentlyAds_message");
    
    [self loadDataWithRefresh:YES];
}

- (void)handleSucceedRequest:(id)results {
    NSArray *listings = results[@"listings"];
    self.itemsTotal = [results[@"calc"] intValue];
    for (NSDictionary *item in listings) {
        NSString *title = item[@"title"];
        NSArray *rows = item[@"rows"];
        NSUInteger indx = [self.headers indexOfObject:title];
        if (indx == NSNotFound) {
            [self.headers addObject:title];
            [self.entries addObject:[rows mutableCopy]];
        }
        else {
            [self.entries[indx] addObjectsFromArray:rows];
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTableSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FLTableSection *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kRecentlyAdsHeaderIdentifier];
    
    if (header == nil)
        header = [[FLTableSection alloc] initWithReuseIdentifier:kRecentlyAdsHeaderIdentifier];
    
    header.textLabel.text = self.headers[section];
    
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(FLTableSection *)view forSection:(NSInteger)section {
    view.textLabel.font = [UIFont boldSystemFontOfSize:15];
    view.textLabel.textColor = [UIColor whiteColor];
}

@end
