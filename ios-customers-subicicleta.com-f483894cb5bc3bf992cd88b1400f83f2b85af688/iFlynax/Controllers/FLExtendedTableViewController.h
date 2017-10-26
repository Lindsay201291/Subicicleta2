//
//  FLExtendedTableView.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 7/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FLInfiniteScrollControl.h"

@interface FLExtendedTableViewController : FLViewController <UITableViewDataSource, UITableViewDelegate, FLInfiniteScrollControlDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) FLInfiniteScrollControl *infScrollControl;
@property (nonatomic) BOOL isTFooterEnabled;
@property (nonatomic, copy) NSString *targetItemName;

@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableArray *entries;

@property (nonatomic) int initStack;
@property (nonatomic) int currentStack;
@property (nonatomic) int itemsTotal;
@property (nonatomic) NSInteger itemsInStack;

@property (nonatomic, copy) NSMutableDictionary *apiParameters;
@property (nonatomic, copy) NSString            *apiItem;
@property (nonatomic, copy) NSString            *apiCmd;

@property (nonatomic) FLBlankSlate *blankSlate;

- (void)loadDataWithRefresh:(BOOL)refresh;

- (void)handleSucceedRequest:(id)results;

- (void)addApiParameter:(id)object forKey:(NSString *)key;
- (void)removeApiParameterForKey:(NSString *)key;

- (void)apiRequestWithCompletion:(FLApiCompletionHandler)completion;

- (IBAction)showSideMenu:(UIBarButtonItem *)sender;

- (void)resignLoadingMessages;

- (void)fadeTableViewIn;

@end
