//
//  FLAccountTypeListViewController.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAccountTypeListViewController.h"
#import "FLAccountDetailsRootViewController.h"
#import "FLAccountCell.h"
#import "FLIndexBarViewCell.h"

static NSString * const barCellRID = @"indexBarSingleCell";

@interface FLAccountTypeListViewController() {
    BOOL _advancedSearch;
}

@property (weak, nonatomic) IBOutlet UIView      *indexBarView;
@property (weak, nonatomic) IBOutlet UITableView *indexTableView;
@property (strong, nonatomic) NSArray            *indexTitles;

@property (copy, nonatomic) NSMutableDictionary *avatarsCache;
@property (strong, nonatomic) UIImage *blankAvatar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginRight;
@end

@implementation FLAccountTypeListViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = FLLocalizedString(@"screen_accounts_alphabetic_search");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:kNibNameAccountViewCell bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kStoryBoardAccountCellIdentifier];

    _advancedSearch = _filterFormData != nil;

    if (!_advancedSearch) {
        NSString *indexesString = FLLocalizedString(@"alphabet_characters");
        _indexTitles        = [indexesString componentsSeparatedByString:@","];
        _filterChar         = [self.indexTitles[0] lowercaseString];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.indexTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        self.indexBarView.backgroundColor = FLHexColor(kColorIndexBarBackground);
        self.indexTableView.allowsSelection = NO;

        self.apiCmd = kApiItemRequests_getAccounts;
    }
    // Agents: advanced search mode
    else {
        self.apiCmd = kApiItemRequests_searchAccounts;
        [self.indexBarView removeFromSuperview];
        [_marginRight setConstant:0];
    }

    self.initStack    = 1;
    self.currentStack = 1;
    
    self.targetItemName = FLLocalizedString(@"inf_scroll_target_accounts");

    [self addApiParameter:_typeModel.key forKey:@"atype"];
    
    self.blankSlate.title   = FLLocalizedString(@"blankSlate_accountType_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_accountType_message");
    
    _avatarsCache = [NSMutableDictionary dictionary];
    _blankAvatar = [UIImage imageNamed:@"blank_avatar"];
    
    [self loadDataWithRefresh:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = F(@"Account Type (%@) - List View", _typeModel.key);
    [super viewDidAppear:animated];
}

- (void)loadDataWithRefresh:(BOOL)refresh {
    if (refresh) {
        [_avatarsCache removeAllObjects];
    }
    [super loadDataWithRefresh:refresh];
}

- (void)apiRequestWithCompletion:(FLApiCompletionHandler)completion {
    if (_advancedSearch) {
        [self addApiParameter:self.filterFormData forKey:@"f"];
    }
    else {
        [self addApiParameter:self.filterChar forKey:@"char"];
    }
    [super apiRequestWithCompletion:completion];
}

- (void)handleSucceedRequest:(id)results {
    
    NSArray *accounts = results[@"accounts"];
    
    if (!accounts.count) {
        if (_advancedSearch) {
            self.blankSlate.message = FLLocalizedString(@"blankSlate_there_no_accounts_found");
        }
        else {
            self.blankSlate.message = F(FLLocalizedString(@"blankSlate_accountTypeChar_message"), [self.filterChar uppercaseString]);
        }
    }
    
    self.itemsTotal = [results[@"calc"] intValue];
    [self.entries addObjectsFromArray:accounts];
    
    self.indexTableView.allowsSelection = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if (tableView == self.tableView)
        numberOfRows = [super tableView:tableView numberOfRowsInSection:section];
    else if (tableView == self.indexTableView)
        numberOfRows = _indexTitles.count;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        FLAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardAccountCellIdentifier];
        
        [self prepareAccountCell:cell atIndexPath:indexPath];
        
        NSString *urlString = self.entries[indexPath.row][@"photo"];
        NSURL *photoUrl = URLIFY(urlString);
        UIImage *avatar = [_avatarsCache objectForKey:urlString];
        
        if (avatar) {
            if (cell.imageView.image != avatar) {
                [self setAvatar:avatar forAccountCell:cell withCacheKey:nil];
            }
            return cell;
        }
        
        if (photoUrl.scheme.length) {
            cell.avatarImageView.contentMode = UIViewContentModeCenter;
            NSURLRequest *request = [NSURLRequest requestWithURL:photoUrl];
            [cell.avatarImageView setImageWithURLRequest:request
                                        placeholderImage:[UIImage imageNamed:@"loading45x45"]
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     if (image) {
                                                         //cell.avatarImageView.image = [image imageScaledToFitSize:cell.avatarImageView.frame.size];
                                                         [self setAvatar:image forAccountCell:cell withCacheKey:urlString];
                                                     }
                                                 }
                                                 failure:^(NSURLRequest *request, NSURLResponse *responce, NSError *error) {
                                                     [self setAvatar:_blankAvatar forAccountCell:cell withCacheKey:urlString];
                                                 }];
        }
        else {
            [self setAvatar:_blankAvatar forAccountCell:cell withCacheKey:urlString];
        }
        
        return cell;
    }
    else if (tableView == self.indexTableView) {
        
        FLIndexBarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:barCellRID];
        cell.charLabel.text = self.indexTitles[indexPath.row];
        
        return cell;
    }
    
    return nil;
}

- (void)setAvatar:(UIImage *)avatar forAccountCell:(FLAccountCell *)cell withCacheKey:(NSString *)cacheKey {
    if (cacheKey) {
        [_avatarsCache setObject:avatar forKey:cacheKey];
    }
    cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.avatarImageView.image = avatar;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        static FLAccountCell *cell = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardAccountCellIdentifier];
        });
        
        [self prepareAccountCell:(FLAccountCell *)cell atIndexPath:(NSIndexPath *)indexPath];
        
        return [self heightForCell:cell];
    }
    return 30;
}

- (CGFloat)heightForCell:(FLAccountCell *)cell {
    cell.bounds = CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, cell.bounds.size.height);

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1.0f;
}


- (void)prepareAccountCell:(FLAccountCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *accountInfo = self.entries[indexPath.row];
    [cell fillWithAccountInfo:accountInfo];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        // go to details controller
        self.isTFooterEnabled = NO;
        
        FLAccountDetailsRootViewController *accountDetails = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountDetailsRootView];
        accountDetails.sellerId = [self.entries[indexPath.row][@"id"] integerValue];
        [self.navigationController pushViewController:accountDetails animated:YES];
    }
    else if (tableView == self.indexTableView) {
        NSString *letter = [self.indexTitles[indexPath.row] lowercaseString];
        if (![letter isEqualToString:self.filterChar]) {
            self.indexTableView.allowsSelection = NO;
            self.filterChar = letter;
            [UIView animateWithDuration:.3f
                             animations:^{
                                 self.tableView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 self.tableView.contentOffset = CGPointMake(0, 0);
                                 [self loadDataWithRefresh:YES];
                             }];
        }
    }
}

@end
