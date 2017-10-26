//
//  FLAdStatistics.m
//  iFlynax
//
//  Created by Alex on 10/14/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLAdStatistics.h"

static NSString * const kCellIdentifier = @"adStatisticsIdentifier";
static NSString * const kItemValue      = @"title";
static NSString * const kItemTitle      = @"value";

@interface FLAdStatistics () {
    NSMutableArray *_entries;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FLAdStatistics

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = FLLocalizedString(@"screen_ad_statistics");
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    _tableView.backgroundColor = self.view.backgroundColor;
    [self.navigationItem.leftBarButtonItem setTitle:FLLocalizedString(@"button_done")];

    _entries = [@[] mutableCopy];

    [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_category"), kItemValue: _listing.categoryName}];
    [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_plan"), kItemValue: _listing.planName}];
    [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_views"), kItemValue: F(@"%d", (int)_listing.views)}];
    [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_status"), kItemValue: _listing.statusStringName}];

    if (![_listing.subStatusString isEmpty]) {
        [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_label"), kItemValue: _listing.subStatusString}];
    }

    [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_added"), kItemValue: _listing.postedDateString}];

    if (![_listing.planExpireString isEmpty]) {
        [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_active_till"), kItemValue: _listing.planExpireString}];
    }

    if (![_listing.featuredExpireString isEmpty]) {
        [_entries addObject:@{kItemTitle: FLLocalizedString(@"stat_featured_till"), kItemValue: _listing.featuredExpireString}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = F(@"Ad Statistics: id#%d", 1);
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _listing.title;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section {
    view.textLabel.text = [view.textLabel.text capitalizedString];
    view.textLabel.font = [UIFont boldSystemFontOfSize:15];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _entries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

	cell.textLabel.text       = FLCleanString(_entries[indexPath.row][kItemTitle]);
    cell.detailTextLabel.text = FLCleanString(_entries[indexPath.row][kItemValue]);
    cell.backgroundColor      = [UIColor clearColor];

	return cell;
}

#pragma mark - Navigation

- (IBAction)closeBtnDidTap:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
