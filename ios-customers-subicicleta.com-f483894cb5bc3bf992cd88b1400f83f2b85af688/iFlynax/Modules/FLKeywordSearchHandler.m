//
//  FLKeywordSearchHandler.m
//  iFlynax
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLKeywordSearchHandler.h"
#import "FLKeywordSearchCell.h"

static NSString * const kKeywordSearchCellIdentifier  = @"keywordSearchCellIdentifier";
static NSString * const kKeywordSearchUserInfoTextKey = @"searchText";
static NSInteger  const kKeywordSearchMinSymbols      = 3;

@interface FLKeywordSearchHandler () <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSInteger _batch;
    NSInteger _total;
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSURLSessionDataTask *ksTask;
@end

@implementation FLKeywordSearchHandler

- (instancetype)initWithSearchDC:(UISearchDisplayController *)searchDC {
    self = [super init];
    if (self) {
        self.searchResultsTableView = searchDC.searchResultsTableView;
        self.searchBar = searchDC.searchBar;
        self.searchDC = searchDC;

        self.searchResultsTableView.backgroundColor = FLHexColor(kColorMenuBackground);
        self.searchResultsTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;

        UIBarButtonItem *cancelButton = [UIBarButtonItem appearanceWhenContainedIn:UISearchBar.class, nil];
        [cancelButton setTitle:FLLocalizedString(@"button_search_cancel")];

        UINib *ksCellNib = [UINib nibWithNibName:kNibNameKeywordSearchCell bundle:nil];
        [self.searchResultsTableView registerNib:ksCellNib forCellReuseIdentifier:kKeywordSearchCellIdentifier];

        self.searchResultsTableView.dataSource = self;
        self.searchResultsTableView.delegate   = self;
        self.searchBar.delegate                = self;
        self.searchDC.delegate                 = self;
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLKeywordSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kKeywordSearchCellIdentifier];

    if ([_entries[indexPath.row] isKindOfClass:NSDictionary.class]) {
        cell.textLabel.text = _entries[indexPath.row][@"title"];
    }
    else if ([_entries[indexPath.row] isKindOfClass:NSString.class]) {
        cell.textLabel.text = _entries[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *listing = _entries[indexPath.row];

    if (_searchResultsCellDidTapBlock) {
        _searchResultsCellDidTapBlock(listing);
    }
}

- (void)filterContentForSearchText:(NSString *)searchText {
    if (searchText.length < 3)
        return;

    _ksTask = [flynaxAPIClient getApiItem:kApiItemRequests
                               parameters:@{@"cmd"  : kApiItemRequests_keywordSearch,
                                            @"query": searchText,
                                            @"stack": @(1)}
                               completion:^(NSDictionary *results, NSError *error) {
                                   if (!error && [results isKindOfClass:NSDictionary.class]) {
                                       _entries = results[@"listings"];
                                       _total   = FLTrueInt(results[@"calc"]);

                                       if (!_total) {
                                           [self updateSearchResultsLabelText:FLLocalizedString(@"keyword_search_no_results")];
                                       }
                                       else [self updateSearchResultsLabelText:nil];
                                   }
                                   else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_keywordSearch];

                                   [self fadeOutSearchResultsTable:NO];
                                   [self reloadSearchResults];
                               }];
}

- (void)reloadSearchResults {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchDC.searchResultsTableView reloadData];
    });
}

- (void)timerFireMethod:(NSTimer *)timer {
    if (timer.isValid) {
        [self filterContentForSearchText:timer.userInfo[kKeywordSearchUserInfoTextKey]];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (_timer != nil && _timer.isValid) {
        if (_ksTask) {
            [_ksTask cancel];
        }
        [_timer invalidate];
    }

    if (searchText.length < kKeywordSearchMinSymbols) {
        if (_entries.count) {
            _entries = @[];
            [self reloadSearchResults];
        }

        BOOL hiddenSearchResults = (searchText.length && searchText.length < kKeywordSearchMinSymbols);
        [self fadeOutSearchResultsTable:(hiddenSearchResults || _ksTask.state == NSURLSessionTaskStateRunning)];

        return;
    }

    _timer = [NSTimer scheduledTimerWithTimeInterval:0.75f target:self selector:@selector(timerFireMethod:)
                                            userInfo:@{kKeywordSearchUserInfoTextKey: searchText} repeats:NO];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self updateSearchResultsLabelText:nil];
}

- (void)updateSearchResultsLabelText:(NSString *)string {
    for (UIView *subview in self.searchResultsTableView.subviews) {
        if (subview.class == UILabel.class) {
            ((UILabel *)subview).text = string;
            break;
        }
    }
}

- (void)fadeOutSearchResultsTable:(BOOL)hide {
    [UIView animateWithDuration:(hide ? 0 : .2f) animations:^{
        self.searchResultsTableView.backgroundColor = FLHexColor(hide ? @"000" : kColorMenuBackground);
        self.searchResultsTableView.alpha           = hide ? .4f : 1.0f;
    }];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    _entries = @[];
}

@end
