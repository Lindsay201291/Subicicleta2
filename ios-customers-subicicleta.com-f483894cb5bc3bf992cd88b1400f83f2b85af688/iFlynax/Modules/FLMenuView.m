//
//  FLMenuView.m
//  iFlynax
//
//  Created by Alex on 4/24/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLCache.h"
#import "FLMenuView.h"
#import "FLMenuItemCell.h"
#import "FLMainNavigation.h"
#import "FLFeedbackView.h"
#import "FLGraphics.h"
#import "FLKeywordSearchHandler.h"

/* controllers */
#import "FLAccountTypeView.h"
#import "FLBrowseView.h"
#import "FLFavorites.h"
#import "FLHomeView.h"
#import "FLAccountTypeRootView.h"
#import "FLAddListingController.h"
#import "FLSearchRootView.h"
#import "FLSearchView.h"

static NSInteger  const kMenuSectionHeight    = 30.0f;
static CGFloat    const kMenuMainPadding      = 10.0f;
static NSString * const kMenuHeaderIdentifier = @"headerIdentifier";

typedef NS_ENUM(NSInteger, FLMenuSection) {
	FLMenuSectionHome,
	FLMenuSectionAccountArea,
	FLMenuSectionBrowse,
	FLMenuSectionAccountTypes,
    FLMenuSectionMore
};

@interface FLMenuHeaderView : UITableViewHeaderFooterView
@property (nonatomic) UILabel *titleLabel;
@end

@implementation FLMenuHeaderView {
    CALayer *_separatorLayer;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = FLHexColor(kColorMenuBackground);
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textColor = FLHexColor(kColorMenuSectionTitle);
        [self addSubview:_titleLabel];
        [self titleLabelContraints];
        
        _separatorLayer = [CALayer layer];
        _separatorLayer.backgroundColor = FLHexColor(kColorMenuSeparator).CGColor;
        [self.layer addSublayer:_separatorLayer];
    }
    return self;
}

- (void)titleLabelContraints {
    
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0f
                                                      constant:kMenuMainPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_titleLabel
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0f
                                                      constant:kMenuMainPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_titleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:1]];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];

    if (layer == self.layer) {
        _separatorLayer.frame = CGRectMake(kMenuMainPadding,
                                           layer.bounds.size.height - 1,
                                           layer.bounds.size.width - kMenuMainPadding * 2,
                                           1);
    }
}
@end

@interface FLMenuView () {
	NSArray *_browseSection;
    NSArray *_accountTypesSection;
	NSIndexPath *_selectedController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) FLKeywordSearchHandler *keywordSearchHandler;
@end

@implementation FLMenuView

- (void)awakeFromNib {
    [super awakeFromNib];

	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.tableview.backgroundColor = self.view.backgroundColor = FLHexColor(kColorMenuBackground);
	self.tableview.backgroundView = nil;
    self.tableview.rowHeight = 48;

    _selectedController = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.tableview registerClass:FLMenuHeaderView.class forHeaderFooterViewReuseIdentifier:kMenuHeaderIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _keywordSearchHandler = [[FLKeywordSearchHandler alloc] initWithSearchDC:self.searchDisplayController];

    __unsafe_unretained typeof(self) weakSelf = self;
    _keywordSearchHandler.searchResultsCellDidTapBlock = ^(NSDictionary *details) {
        FLMainNavigation *navigator = (FLMainNavigation *)weakSelf.frostedViewController.contentViewController;
        FLAdDetailsRootView *listingDetails = [weakSelf.storyboard instantiateViewControllerWithIdentifier:kStoryBoardadDetailsRootView];
        listingDetails.shortDetails = [FLAdShortDetailsModel fromDictionary:details];

        [weakSelf.searchDisplayController.searchBar resignFirstResponder];
        [weakSelf.frostedViewController hideMenuViewControllerWithCompletionHandler:^{
            [navigator pushViewController:listingDetails animated:YES];
        }];
    };
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	dispatch_async(dispatch_get_main_queue(), ^{
		_browseSection = [[FLListingTypes sharedInstance] buildBrowseMenuSection];
        _accountTypesSection = [[FLAccountTypes sharedInstance] buildAccountTypesMenuSection];
		[_tableview reloadData];
	});
    _keywordSearchHandler.searchBar.placeholder = FLLocalizedString(@"placeholder_keyword_search");
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (section == FLMenuSectionHome) ? 0.0f : kMenuSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == FLMenuSectionHome)
		return nil;

    section = [self skipAccountTypesSectionIfNecessary:section];
	FLMenuHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kMenuHeaderIdentifier];
    
    headerView.titleLabel.text = [[self headerTitleInSection:section] uppercaseString];
	
    return headerView;
}

- (NSString *)headerTitleInSection:(NSInteger)section {
    section = [self skipAccountTypesSectionIfNecessary:section];

	switch (section) {
		case FLMenuSectionAccountArea:
			return FLLocalizedString(@"menu_section_account");
		case FLMenuSectionBrowse:
			return FLLocalizedString(@"menu_section_browse");
		case FLMenuSectionAccountTypes:
			return FLLocalizedString(@"menu_section_account_types");
        case FLMenuSectionMore:
            return FLLocalizedString(@"menu_section_more");
	}
	return nil;
}

#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _browseSection != nil
    ? (_accountTypesSection.count ? 5 : 4)
    : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_browseSection == nil)
		return 0;

    section = [self skipAccountTypesSectionIfNecessary:section];

	switch (section) {
		case FLMenuSectionHome:
			return 1;
		case FLMenuSectionAccountArea:
            return IS_LOGIN ? ([FLAccount canPostAds] ? 5 : 3) : 3;
		case FLMenuSectionBrowse:
			return _browseSection.count;
		case FLMenuSectionAccountTypes:
            return _accountTypesSection.count;
        case FLMenuSectionMore:
            return 3;
	}
	return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FLMenuItemCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectedController compare:indexPath] == NSOrderedSame) {
        [cell setSelected:YES animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLMenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardMenuItemCell];
    CGFloat section = [self skipAccountTypesSectionIfNecessary:indexPath.section];

    cell.iconView.image = [UIImage imageNamed:@"menu_icon_default"];
	[cell setBadgeString:nil];
    cell.bottomSeparator = YES;
    
	if (section == FLMenuSectionHome) {
		cell.titleLabel.text = FLLocalizedString(@"menu_home");
        cell.bottomSeparator = NO;
	}

    else if (section == FLMenuSectionAccountArea) {
		NSMutableArray *titleKeys = [NSMutableArray array];

		if (IS_LOGIN) {
			NSString *username = [FLAccount fullName] ?: @"my_profile";
            [titleKeys addObject:username];

            if ([FLAccount canPostAds]) {
                [titleKeys addObjectsFromArray:@[@"menu_add_listing", @"menu_my_listings"]];
            }
            [titleKeys addObjectsFromArray:@[@"menu_my_messages", @"menu_favorites"]];
		}
        else {
            [titleKeys addObjectsFromArray:@[@"menu_login", @"menu_add_listing", @"menu_favorites"]];
        }

		cell.titleLabel.text = FLLocalizedString(titleKeys[indexPath.row]);
		NSString *icon = (indexPath.row == 0) ? @"menu_login" : titleKeys[indexPath.row];
		cell.iconView.image = [UIImage imageNamed:icon];

        if (IS_LOGIN && indexPath.row == titleKeys.count - 2) { // my_messages
            if ([FLAccount newMessageCount]) {
                [cell setBadgeInteger:[FLAccount newMessageCount]];
            }
        }
		else if (indexPath.row == titleKeys.count - 1) { // favorites
            cell.bottomSeparator = NO;
		}
	}

	else if (section == FLMenuSectionBrowse) {
        NSString *rowTitle;
        NSString *rowImageName;

        if ([_browseSection[indexPath.row] isKindOfClass:NSDictionary.class]) {
            NSDictionary *sectionInfo = _browseSection[indexPath.row];
            rowImageName = sectionInfo[@"icon"];
            rowTitle = sectionInfo[@"name"];

            if ([sectionInfo[@"icon"] isEqualToString:@"menu_search_around_me"]) {
                [self forceSelectTheItem:indexPath ifCacheHaveKey:kSessionStaticMapDidTapped];
            }
            else if ([sectionInfo[@"icon"] isEqualToString:@"menu_search"]) {
                [self forceSelectTheItem:indexPath ifCacheHaveKey:kSessionSearchControllerIsActive];
            }
        }
        else {
            FLListingTypeModel *listingType = _browseSection[indexPath.row];
            rowImageName = listingType.icon;
            rowTitle = listingType.name;
        }

        UIImage *menuIcon = [UIImage imageNamed:rowImageName];
        if (menuIcon) {
            cell.iconView.image = menuIcon;
        }
        cell.titleLabel.text = rowTitle;

        if (indexPath.row == _browseSection.count - 1) {
            cell.bottomSeparator = NO;
        }
	}

	else if (section == FLMenuSectionAccountTypes) {
        FLAccountTypeModel *accountType = _accountTypesSection[indexPath.row];
		cell.titleLabel.text = accountType.name;

        if (indexPath.row == _accountTypesSection.count - 1) {
            cell.bottomSeparator = NO;
        }
	}

    else if (section == FLMenuSectionMore) {
        NSString *menuImageName;

        if (indexPath.row == 0) {
            cell.titleLabel.text = FLLocalizedString(@"menu_settings");
            menuImageName = @"menu_settings";
        }
        else if (indexPath.row == 1) {
            cell.titleLabel.text = FLLocalizedString(@"menu_about_app");
            menuImageName = @"menu_about_app";
        }
        else if (indexPath.row == 2) {
            cell.titleLabel.text = FLLocalizedString(@"menu_feedback");
            menuImageName = @"menu_feedback";
            cell.bottomSeparator = NO;
        }
        cell.iconView.image = [UIImage imageNamed:menuImageName];
    }
    cell.titleLabel.textAlignment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat section = [self skipAccountTypesSectionIfNecessary:indexPath.section];
	id contentViewController = nil;
	NSString *controllerIdentifier = nil;
    BOOL presentationVC = NO;

    if (section == FLMenuSectionHome)
		contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardHomeView];

	// ACCOUNT AREA
	else if (section == FLMenuSectionAccountArea) {
		NSInteger numberRows = [tableView numberOfRowsInSection:section];

		if (IS_LOGIN) {

            // MY ACCOUNT
			if (indexPath.row == 0)
				controllerIdentifier = kStoryBoardMyProfileRootView;

            // ADD LISTINGS
            else if (indexPath.row == 1) {
                if ([FLAccount canPostAds]) {
                    controllerIdentifier = kStoryBoardAAFillOutFormView;
                    presentationVC       = YES;
                }
                else
                    controllerIdentifier = kStoryBoardMyMessagesView;
            }

            //MY LISTINGS
            else if (indexPath.row == 2) {
                if ([FLListingTypes typesCount] == 1)
                    controllerIdentifier = kStoryBoardMyListingsView;
                else
                    controllerIdentifier = kStoryBoardMyListingsRootView;
            }

            // MY MESSAGES
            else if (indexPath.row == 3)
                controllerIdentifier = kStoryBoardMyMessagesView;
		}
		else {

            // AUTH SCREEN
            if (indexPath.row == 0 || indexPath.row == 1) {
				controllerIdentifier = kStoryBoardLoginFormView;

                // Post ad
                if (indexPath.row == 1) {
                    [FLAppSession addItem:@(YES) forKey:kSessionPostAdScreenAfterLogin];
                }
            }
		}

        // FAVORITES
        if (indexPath.row == numberRows-1)
			controllerIdentifier = kStoryBoardFavoriteAdsView;

		// assign controller
		if (controllerIdentifier != nil)
			contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
	}

	// BROWSE
	else if (section == FLMenuSectionBrowse) {
		if (indexPath.row == 0) {
			if ([FLListingTypes typesCount] == 1) {
				contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardRecentlyAdsView];
			}
			else {
				contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardRecentlyAdsRootView];
			}
		}
		else if (indexPath.row == 1) {
			contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardNearbyAdsView];
		}
        /* Search */
        else if (indexPath.row == 2) {
            static NSDictionary *_forms;
            _forms = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSearchFormsKey];

            if (_forms.count > 1) {
                FLSearchRootView *searchRootVC =
                [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSearchRootView];
                searchRootVC.forms = _forms;

                contentViewController = searchRootVC;
            }
            else if (_forms.count == 1) {
                FLListingTypeModel *mainType = [[FLListingTypes sharedInstance] mainType];

                FLSearchView *searchVC =
                [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSearchView];
                searchVC.fields      = _forms[mainType.key] ?: @[];
                searchVC.title       = mainType.name;
                searchVC.listingType = mainType;

                contentViewController = searchVC;
            }
            else {
                [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_search_forms_arent_configured")];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
        }
        /* Search END */
		else {
            FLBrowseView *browseViewController;
            FLListingTypeModel *listingType = _browseSection[indexPath.row];

            browseViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardBrowseView];
			browseViewController.title = listingType.name;
			browseViewController.lType = listingType;
			contentViewController = browseViewController;
		}
	}

    // ACCOUNT TYPES
    else if (section == FLMenuSectionAccountTypes) {
        FLAccountTypeModel *accountType = _accountTypesSection[indexPath.row];
        if (accountType.searchForm) {
            FLAccountTypeRootView *accountTypeController;
            accountTypeController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountTypeRootView];
            accountTypeController.title = accountType.name;
            contentViewController = accountTypeController;
        }
        else {
            contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountTypeListViewController];
        }
        [contentViewController setTypeModel:accountType];
    }

    else if (section == FLMenuSectionMore) {
        if (indexPath.row == 2) {
            contentViewController = [[FLFeedbackView alloc] init];
        }
        else {
            NSString *controllerIdentifier;
            switch (indexPath.row) {
                case 0:
                    controllerIdentifier = kStoryBoardSettingsView;
                    break;
                case 1:
                    controllerIdentifier = kStoryBoardAboutUsView;
                    break;
            }
            contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:controllerIdentifier];
        }
    }

	// deep checking..
	if (contentViewController != nil) {
        if (presentationVC) {
            [self.frostedViewController hideMenuViewControllerWithCompletionHandler:^{
                UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                FLAddListingController *addListingVC = (FLAddListingController *)contentViewController;
                [rootController presentViewController:addListingVC.flNavigationController animated:YES completion:nil];
            }];
        }
        else {
            if ([FLAppSession itemWithKey:kSessionPostAdScreenAfterLogin] != nil) {
                _selectedController = [NSIndexPath indexPathForRow:0 inSection:1];
            } else {
                _selectedController = indexPath;
            }

            FLMainNavigation *navigationController =
            [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardContentController];
            navigationController.viewControllers = @[contentViewController];
            self.frostedViewController.contentViewController = navigationController;
        }
	}
	else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"error_code_unknown")];

    if (!presentationVC) {
        [self.frostedViewController hideMenuViewController];
    }
}

- (CGFloat)skipAccountTypesSectionIfNecessary:(CGFloat)section {
    if (!_accountTypesSection.count && section == FLMenuSectionAccountTypes) {
        section++;
    }
    return section;
}

// TODO: review me! and update
- (void)forceSelectTheItem:(NSIndexPath *)indexPath ifCacheHaveKey:(NSString *)cacheKey {
    if (FLAppSessionWithKey(cacheKey)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadData];
        });
        [FLAppSession removeItemWithKey:cacheKey];
        _selectedController = indexPath;
    }
}

@end

