//
//  FLBrowseView.m
//  iFlynax
//
//  Created by Alex on 10/28/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLNavigationController.h"
#import "FLBrowseActionsView.h"
#import "FLSearchRootView.h"
#import "CCActionSheet.h"
#import "FLSearchView.h"
#import "FLBrowseView.h"

#import "FLSubCategoriesVC.h"

static NSString * const kCategoriesCellIdentifier = @"categoriesCellIdentifier";
static NSString * const kBrowseCellIdentifier     = @"browseCellIdentifier";

@interface FLBrowseView () <FLBrowseActionsViewDelegate, FLSubCategoriesVCDelegate>
@property (strong, nonatomic) FLSubCategoriesVC *categoriesTableView;
@property (weak, nonatomic) IBOutlet FLBrowseActionsView *actions;
@property (strong, nonatomic) NSDictionary *currentSortingField;
@property (strong, nonatomic) NSArray *sortingFields;
@end

@implementation FLBrowseView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.blankSlate.title   = FLLocalizedString(@"blankSlate_browse_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_browse_message");

    [self categoryOrAds];
    [self loadDataWithRefresh:YES];
}

- (void)categoryOrAds {
    if (_lCategory) {
        _actions.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        UIImage *searchIcon = [UIImage imageNamed:@"search"];
        UIBarButtonItem *searchBtn = [[UIBarButtonItem alloc] initWithImage:searchIcon
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(searchBtnTapped:)];
        searchBtn.tag = FLBrowseActionsBtnSearch;
        self.navigationItem.rightBarButtonItem = searchBtn;
    }
}

- (NSDictionary *)apiParams {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (_lCategory) {
        params = [@{@"cmd"   : kApiItemRequests_listingsByCategory,
                   @"ltype" : self.lType.key,
                   @"cid"   : @(_lCategory.cId),
                   @"stack" : @(self.currentStack)} mutableCopy];

        if (_currentSortingField) {
            params[@"sort"] = @{@"by"  : _currentSortingField[@"by"],
                                @"type": _currentSortingField[@"type"]};
        }
    }
    else {
        params = [@{@"cmd"        : kApiItemRequests_categories,
                   @"ltype_key"  : self.lType.key,
                   @"category_id": @0} mutableCopy];
    }

    return params;
}


- (void)apiRequestWithCompletion:(FLApiCompletionHandler)completion {
    
    [self.apiParameters removeAllObjects];
    [self.apiParameters addEntriesFromDictionary:[self apiParams]];
    
    [super apiRequestWithCompletion:completion];
}

- (void)handleSucceedRequest:(id)results {
    if (_lCategory) {
        [super handleSucceedRequest:results];
        
        if (!_sortingFields) {
            _sortingFields = results[@"sorting"];
        }
        
        NSArray *subCategories = results[@"categories"];
        if (subCategories && subCategories.count) {
            self.lCategory.subCategories = subCategories;
        }
        
        _actions.sorting = (_sortingFields != nil && self.entries.count > 1);
        _actions.subCategories = _lCategory.subCategories.count ? YES : NO;
        [_actions setNeedsDisplay];
    }
    else {
        if ([results count] == 1) {
            _lCategory = [FLCategoryModel fromDictionary:results[0]];

            //TODO: show listings of only category in a proper way
            [self viewDidLoad];
        }
        else {
            [self.entries addObjectsFromArray:results];
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (tableView == self.categoriesTableView.tableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCategoriesCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCategoriesCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        [self fillUpCategoriesCell:cell ForRowAtIndexPath:indexPath withData:_lCategory.subCategories[indexPath.row]];
        
    }
    else if (_lCategory) {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kBrowseCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        [self fillUpCategoriesCell:cell ForRowAtIndexPath:indexPath withData:self.entries[indexPath.row]];
    }
    cell.textLabel.textAlignment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;

    return cell;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.categoriesTableView.tableView) {
        return _lCategory.subCategories.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_lCategory && tableView == self.tableView) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tableView == self.categoriesTableView.tableView) {
        NSDictionary *itemInfo = _lCategory.subCategories[indexPath.row];

        if (itemInfo.count) {
            [self.frostedViewController hideMenuViewControllerWithCompletionHandler:^{
                [self pushToNextCategoryWithData:itemInfo];
            }];
        }
    }
    else {
        if (_lCategory == nil) {
            [self pushToNextCategoryWithData:self.entries[indexPath.row]];
        }
        else {
            [super pushDetailsForIndexPath:indexPath];
        }
    }
}

#pragma mark - FLBrowseActionsViewDelegate

- (void)searchBtnTapped:(UIButton *)button {
    [self actionsViewButtonTapped:button.tag];
}

- (void)actionsViewButtonTapped:(FLBrowseActionsBtn)button {
    switch (button) {
        case FLBrowseActionsBtnSorting:
            [self displaySortingUI];
            break;

        case FLBrowseActionsBtnSubCategories:
            [self displaySubCategoriesUI];
            break;

        case FLBrowseActionsBtnSearch:
            [self moveToSearch];
            break;
    }
}

- (void)moveToSearch {
    static NSDictionary *_forms;
    _forms = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSearchFormsKey];

    if (_forms.count > 1) {
        FLSearchRootView *searchRootVC =
        [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSearchRootView];
        searchRootVC.forms = _forms;

        FLNavigationController *searchRootNC = [[FLNavigationController alloc] initWithRootViewController:searchRootVC];
        [self.frostedViewController setContentViewController:searchRootNC];
    }
    else if (_forms.count == 1) {
        FLListingTypeModel *mainType = [[FLListingTypes sharedInstance] mainType];

        FLSearchView *searchVC =
        [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSearchView];
        searchVC.fields      = _forms[mainType.key] ?: @[];
        searchVC.title       = mainType.name;
        searchVC.listingType = mainType;

        FLNavigationController *searchRootNC = [[FLNavigationController alloc] initWithRootViewController:searchVC];
        [self.frostedViewController setContentViewController:searchRootNC];
    }
    else {
        [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_search_forms_arent_configured")];
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)displaySortingUI {
    CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:FLLocalizedString(@"sort_listings_by")];
    for (NSDictionary *field in _sortingFields) {
        NSString *_title = field[@"title"];
        NSDictionary *_sortingField = [self sortFieldWithKey:field[@"skey"] type:field[@"stype"]];
        BOOL _isEqualSortingDictionary = [_currentSortingField isEqualToDictionary:_sortingField];

        if (_currentSortingField && _isEqualSortingDictionary) {
            _title = F(@"✓ %@", field[@"title"]);
        }

        [sheet addButtonWithTitle:FLTrueString(_title) block:^{
            if (!_isEqualSortingDictionary) {
                _currentSortingField = _sortingField;
                
                [self addApiParameter:_sortingField forKey:@"sort"];
                [self loadDataWithRefresh:YES];
            }
        }];
    }
    [sheet addCancelButtonWithTitle:FLLocalizedString(@"button_cancel")];
    [sheet showInView:self.view];
}

- (NSDictionary *)sortFieldWithKey:(NSString *)key type:(NSString *)type {
    return @{@"by"  : key,
             @"type": type};
}

- (void)displaySubCategoriesUI {
    self.frostedViewController.direction = IS_RTL
    ? REFrostedViewControllerDirectionLeft
    : REFrostedViewControllerDirectionRight;

    self.frostedViewController.menuViewController = self.categoriesTableView;

    self.categoriesTableView.entries = _lCategory.subCategories;
    [self.frostedViewController presentMenuViewController];
}

- (FLSubCategoriesVC *)categoriesTableView {
    if (_categoriesTableView == nil) {
        _categoriesTableView = [[FLSubCategoriesVC alloc] initWithStyle:UITableViewStylePlain];
        _categoriesTableView.parentVC = self;
    }
    return _categoriesTableView;
}

- (void)pushToNextCategoryWithData:(NSDictionary *)categoryEntry {
    FLBrowseView *browseController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardBrowseView];
    browseController.navigationItem.leftBarButtonItem = [[UINavigationItem alloc] backBarButtonItem];
    browseController.lCategory = [FLCategoryModel fromDictionary:categoryEntry];
    browseController.title = browseController.lCategory.name;
    browseController.lType = self.lType;

    [self.navigationController pushViewController:browseController animated:YES];
}


#pragma mark - Helpers

- (void)fillUpCategoriesCell:(UITableViewCell *)cell ForRowAtIndexPath:(NSIndexPath *)indexPath withData:(NSDictionary *)data {
    
    int listingsCount = FLTrueInt(data[@"count"]);
    NSString *countText = F(@" (%d)", listingsCount);
    NSString *cellTitle = F(@"%@%@", data[@"name"], countText);

    if (listingsCount) {
        NSMutableAttributedString *attributedCellTitle = [[NSMutableAttributedString alloc] initWithString:cellTitle];
        NSRange rangeOfCount = [cellTitle rangeOfString:countText];
        [attributedCellTitle addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"4e575b"] range:NSMakeRange(0, cellTitle.length)];
        [attributedCellTitle addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:rangeOfCount];
        cell.textLabel.attributedText = attributedCellTitle;
    }
    else {
        cell.textLabel.text = cellTitle;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
}

#pragma mark - FLSubCategoriesVCDelegate

- (void)fillUpSubCategoryCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withData:(NSDictionary *)data {
    [self fillUpCategoriesCell:cell ForRowAtIndexPath:indexPath withData:data];
}

- (void)goToSubCategoryWithData:(NSDictionary *)data {
    [self.frostedViewController hideMenuViewControllerWithCompletionHandler:^{
        [self pushToNextCategoryWithData:data];
    }];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    UIViewController *mainAppSideMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.frostedViewController.menuViewController = mainAppSideMenu;

    self.frostedViewController.direction = IS_RTL
    ? REFrostedViewControllerDirectionRight
    : REFrostedViewControllerDirectionLeft;

	[self.frostedViewController presentMenuViewController];
}


@end
