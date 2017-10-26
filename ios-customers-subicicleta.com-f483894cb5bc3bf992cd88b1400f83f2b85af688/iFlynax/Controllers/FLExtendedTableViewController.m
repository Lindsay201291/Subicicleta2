//
//  FLExtendedTableView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLExtendedTableViewController.h"
#import "REFrostedViewController.h"

static NSString * const kDefaultEmptyImageName = @"empty_placeholder_logo";
static CGFloat const kInfiniteScrollHeight = 60.0f;

@implementation FLExtendedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    // UI
    _tableView.alpha = 0;
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    _tableView.backgroundColor = self.view.backgroundColor;
    
    // init EmptyDataSet
    _tableView.emptyDataSetDelegate = self;
    _tableView.emptyDataSetSource = self;
    _blankSlate = [[FLBlankSlate alloc] init];
    _blankSlate.title = @"title";
    _blankSlate.message = @"message";
    
    // init basic properties
    _entries      = [NSMutableArray new];
    _headers      = [NSMutableArray new];
    _itemsTotal   = 0;
    _initStack    = 0;
    _currentStack = _initStack;
    _itemsInStack = [FLConfig displayListingsNumberPerPage];
    
    // init refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setTintColor:FLHexColor(kColorBarTintColor)];
    [_refreshControl addTarget:self action:@selector(refreshOnPull:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _apiItem = kApiItemRequests;
    
    // init infinite scroll control
    CGRect isFrame             = CGRectMake(0, 0, self.view.width, kInfiniteScrollHeight);
    _infScrollControl          = [FLInfiniteScrollControl initWithRect:isFrame];
    _infScrollControl.delegate = self;
    _tableView.tableFooterView = _infScrollControl;
    
    self.isTFooterEnabled = NO;
}


- (void)setIsTFooterEnabled:(BOOL)enabled {
    _isTFooterEnabled = enabled;
    _tableView.tableFooterView.hidden = !enabled;

    UIEdgeInsets insets = _tableView.contentInset;
    insets.bottom = enabled ? 0 : 1 - _tableView.tableFooterView.bounds.size.height;
    _tableView.contentInset = insets;
}

- (void)resignLoadingMessages {
    
    [_infScrollControl defineMessagesWithTotal:_itemsTotal
                             withCurrentAmount:_entries.count
                                     withBatch:_itemsInStack
                                    withTarget:_targetItemName];
}

#pragma mark - Data managing

- (void)loadDataWithRefresh:(BOOL)refresh {
    if (!_apiItem) {
        return;
    }

    if (refresh) {
        _currentStack = _initStack;
        if (!_refreshControl.isRefreshing) {
            [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
        }
    }

    if (refresh && _isTFooterEnabled) {
        self.isTFooterEnabled = NO;
    }

    if (_apiCmd) {
        [self addApiParameter:_apiCmd forKey:@"cmd"];
    }

    [self addApiParameter:@(_currentStack) forKey:@"stack"];

    [self apiRequestWithCompletion:^(id results, NSError *error) {
        if (error) {
            NSString *errorApiItem = _apiCmd ?: _apiItem;
            [FLDebug showAdaptedError:error apiItem:errorApiItem];
        }
        else {
            if (refresh) {
                [_entries removeAllObjects];
                [_headers removeAllObjects];
            }

            [self handleSucceedRequest:results];
            [self resignLoadingMessages];

            _currentStack++;

            dispatch_async(dispatch_get_main_queue(), ^{
                [_infScrollControl setLoading:NO];
                [_refreshControl endRefreshing];
                [_tableView reloadData];

                [UIView animateWithDuration:.3f animations:^{
                    self.tableView.alpha = 1;
                }];
            });
        }
        [FLProgressHUD dismiss];
        _tableView.scrollEnabled = YES;
    }];
}

- (void)addApiParameter:(id)object forKey:(NSString *)key {
    if (!_apiParameters)
        _apiParameters = [NSMutableDictionary new];
    
    [_apiParameters setValue:object forKey:key];
}

- (void)removeApiParameterForKey:(NSString *)key {
    if (!_apiParameters) return;

    [_apiParameters setValue:nil forKey:key];
}

- (void)apiRequestWithCompletion:(FLApiCompletionHandler)completion {
    
    [flynaxAPIClient getApiItem:_apiItem
                     parameters:_apiParameters
                     completion:completion];
}

- (void)handleSucceedRequest:(id)results {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return !_entries.count ? 0 : _headers.count ?: 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _headers.count ? [_entries[section] count] : _entries.count ?: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        // apply only to the last cell
        if (indexPath.section + 1 == [_tableView numberOfSections] && indexPath.row + 1 == [tableView numberOfRowsInSection:indexPath.section]) {
            self.isTFooterEnabled = (_initStack == _currentStack && _itemsTotal > _itemsInStack) || ((_currentStack - _initStack) * _itemsInStack < _itemsTotal);

            if (_isTFooterEnabled && _infScrollControl.infiniteScroll) {
                [self loadDataWithRefresh:NO];
            }
        }
    }
}

#pragma mark - Refresh control handler

- (void)refreshOnPull:(UIRefreshControl *)sender {
    if (sender == _refreshControl) {
        _tableView.scrollEnabled = NO;
        [self refreshData];
    }
}

- (void)refreshData {
    [self loadDataWithRefresh:YES];
}

#pragma mark - FLInfiniteScrollControlDelegate

- (void)flInfiniteScrollControl:(FLInfiniteScrollControl *)control loadMoreButtonTaped:(UIButton *)button {
    [self loadDataWithRefresh:NO];
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (_blankSlate.title == nil) {
        return nil;
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    return [[NSAttributedString alloc] initWithString:_blankSlate.title attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (_blankSlate.message == nil) {
        return nil;
    }
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    return [[NSAttributedString alloc] initWithString:_blankSlate.message attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:kDefaultEmptyImageName];
}

#pragma mark - DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Appereance

- (void)fadeTableViewIn {
    [UIView animateWithDuration:.3f animations:^() {
        self.tableView.alpha = 1;
    }];
}

@end
