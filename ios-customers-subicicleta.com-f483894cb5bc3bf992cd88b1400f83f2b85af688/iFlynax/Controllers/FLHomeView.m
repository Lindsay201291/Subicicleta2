//
//  FLHomeView.m
//  iFlynax
//
//  Created by Alex on 4/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLHomeView.h"
#import "FLStaticMap.h"
#import "FLMainNavigation.h"
#import "REFrostedViewController.h"
#import "FLAdsCollectionCell.h"
#import "FLHomeLayout.h"
#import "FLCollectionLoadingView.h"
#import "FLInfiniteScrollControl.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FLNavigationController.h"

// controllers
#import "FLDetailsView.h"
#import "FLNearbyAdsView.h"
#import "FLSearchRootView.h"
#import "FLSearchView.h"

typedef NS_ENUM(NSInteger, FLRefreshAdsState) {
	FLRefreshAdsStateNormal,
	FLRefreshAdsStateLoading,
	FLRefreshAdsStateBloked,
};

@interface FLHomeView () <UICollectionViewDataSource, UICollectionViewDelegate, FLInfiniteScrollControlDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    NSInteger _batch;
    NSInteger _total;
    BOOL _showISConrol;
    UIEdgeInsets cwContentInstets;
}

@property (weak, nonatomic) FLHomeViewControllerView *view;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
/*@property (weak, nonatomic) IBOutlet FLStaticMap *nearbyAdsBanner;*/
@property (weak, nonatomic) IBOutlet UILabel *errorsDebugLabel;
@property (assign, nonatomic) FLRefreshAdsState adsCurrentState;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *entries;
@property (assign, nonatomic) NSInteger stack;
@property (strong, nonatomic) UIImage *loadingImage;
@property (nonatomic) BOOL isTFooterEnabled;

@property (strong, nonatomic) FLInfiniteScrollControl *footerISControlView;
@end

@implementation FLHomeView
@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    
   /* [self.nearbyAdsBanner setHidden:(YES)]; */ //New change by Lindsay

    // switch to RTL if necessary
    self.frostedViewController.direction = IS_RTL
    ? REFrostedViewControllerDirectionRight
    : REFrostedViewControllerDirectionLeft;

	self.title = FLLocalizedString(@"screen_subicicleta");
	
    _batch   = [FLConfig displayListingsNumberPerPage];
    _entries = [NSMutableArray array];
    _stack   = 1;
    
    _loadingImage = [UIImage imageNamed:@"loading45x45"];
    
    // update static map with current user location
	/*[_nearbyAdsBanner updateUserLocationOnMap];

    __typeof (&*self) __weak weakSelf = self;
    _nearbyAdsBanner.onTap = ^{
        UIViewController *vc = [weakSelf.storyboard instantiateViewControllerWithIdentifier:kStoryBoardNearbyAdsView];
        FLNavigationController *nc = [[FLNavigationController alloc] initWithRootViewController:vc];

        [FLAppSession addItem:@1 forKey:kSessionStaticMapDidTapped];
        [weakSelf.frostedViewController setContentViewController:nc];
    };*/

	// append refresh control
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl setTintColor:FLHexColor(kColorBarTintColor)];
	[_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
	[_collectionView addSubview:_refreshControl];

    // attach blank slate to the collection view
    [FLBlankSlate attachTo:self.collectionView
                 withTitle:FLLocalizedString(@"blankSlate_home_title")];

    _isTFooterEnabled = NO;

	// load listings from cache if exists
	NSDictionary *cacheWithAds = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheHomeScreenAdsKey];
	if (cacheWithAds != nil) {
        NSArray *_listings = cacheWithAds[@"listings"];

        if ([_listings isKindOfClass:NSArray.class] && _listings.count) {
            _total   = [cacheWithAds[@"calc"] integerValue];
            _entries = [_listings mutableCopy];
            _stack  += _entries.count / _batch;
        }
		else [self refreshFeaturedAds:NO];
	}
    else [self refreshFeaturedAds:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = self.title;
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)setIsTFooterEnabled:(BOOL)enabled {
    _isTFooterEnabled = enabled;
    _footerISControlView.hidden = !enabled;
    
    UIEdgeInsets insents = _collectionView.contentInset;
    insents.bottom = enabled ? 0 : - _footerISControlView.bounds.size.height - 5;
    _collectionView.contentInset = insents;
}

#pragma mark - Common

- (void)handleRefresh:(UIRefreshControl *)sender {
	[self refreshFeaturedAds:NO];
}

- (void)refreshFeaturedAds:(BOOL)append {
	[self setAdsCurrentState:FLRefreshAdsStateLoading];
	if (!append) _stack = 1;
    
	[flynaxAPIClient getApiItem:kApiItemHome
					 parameters:@{@"stack": @(_stack)}
					 completion:^(NSDictionary *results, NSError *error) {
						 if (error == nil && [results isKindOfClass:NSDictionary.class] && results[@"listings"] != nil) {
                             NSArray *listings = results[@"listings"];
                             _total = [results[@"calc"] integerValue];

                             /* save to storage for future purpose */
                             if (_stack == 1) {
                                 [[NSUserDefaults standardUserDefaults] setObject:results forKey:kCacheHomeScreenAdsKey];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                             }
                             /* save to storage for future purpose END */

                             if (!append && _entries.count) {
                                 [_entries removeAllObjects];
                             }

							 if (listings.count) {
								 [self setAdsCurrentState:FLRefreshAdsStateNormal];
								 [_entries addObjectsFromArray:listings];
                                 _stack++;
							 }
							 else [self setAdsCurrentState:FLRefreshAdsStateBloked];

							 dispatch_async(dispatch_get_main_queue(), ^{
								 [_collectionView reloadData];
								 [_refreshControl endRefreshing];
							 });

                             _footerISControlView.loading = NO;
						 }
						 else {
							 [FLDebug showAdaptedError:error apiItem:kApiItemHome];
							 [self setAdsCurrentState:FLRefreshAdsStateNormal];

							 dispatch_async(dispatch_get_main_queue(), ^{
								 [_refreshControl endRefreshing];
								 [_collectionView reloadData];
							 });
						 }
					 }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _entries.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    _footerISControlView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:kStoryBoardHomeCollectionLoading
                                                                         forIndexPath:indexPath];
    _footerISControlView.delegate = self;
    self.isTFooterEnabled = (_total > _entries.count);

    return _footerISControlView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FLAdsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStoryBoardHomeCollectionItemCell
																		  forIndexPath:indexPath];
    FLAdShortDetailsModel *listing = [FLAdShortDetailsModel fromDictionary:_entries[indexPath.row]];

	cell.adTitle.text = listing.title;
	cell.adPrice.text = listing.price;
    cell.adThumbnail.contentMode = UIViewContentModeCenter;
    cell.layer.borderWidth = 0;

	// load thumbnail
	if (listing.thumbnail.scheme.length) {
		NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:listing.thumbnail];
		[thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
		[cell.adThumbnail setImageWithURLRequest:thumbnailRequest
								placeholderImage:self.loadingImage
										 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
											 if (image) {
												 cell.adThumbnail.image = image;
                                                 cell.adThumbnail.contentMode = UIViewContentModeScaleAspectFill;
											 }
										 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             [self setNoImageForCell:cell];
                                         }];
	}
    else {
        [self setNoImageForCell:cell];
    }
	return cell;
}

- (void)setNoImageForCell:(FLAdsCollectionCell *)cell {
    cell.adThumbnail.image = [UIImage imageNamed:@"no_image"];
    cell.layer.borderColor = FLHexColor(kColorBarTintColor).CGColor;
    cell.layer.borderWidth = .5f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FLAdDetailsRootView *listingDetails = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardadDetailsRootView];
    listingDetails.shortDetails = [FLAdShortDetailsModel fromDictionary:_entries[indexPath.row]];
    [self.navigationController pushViewController:listingDetails animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    [_footerISControlView defineMessagesWithTotal:_total
                                withCurrentAmount:_entries.count
                                        withBatch:_batch
                                       withTarget:FLLocalizedString(@"inf_scroll_target_ads")];
    
    if (_isTFooterEnabled && _footerISControlView.infiniteScroll) {
        [self refreshFeaturedAds:YES];
    }
}

#pragma mark - FLInfiniteScrollControlDelegate

- (void)flInfiniteScrollControl:(FLInfiniteScrollControl *)control loadMoreButtonTaped:(UIButton *)button {
    [self refreshFeaturedAds:YES];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)searchBtnDidTap:(UIBarButtonItem *)sender {
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

- (void)updateNecessaryConstraintsForBannerView {
    [self.view updateNecessaryConstraintsForBanner:self.googleAd];
}

@end

@interface FLHomeViewControllerView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet FLStaticMap *staticMap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottomIndentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *staticMapBottomInentContraint;
@end

@implementation FLHomeViewControllerView

- (void)updateNecessaryConstraintsForBanner:(FLGoogleAdModel *)banner {
    if (banner.position == FLBannerPositionTop) {
        self.collectionViewTopConstraint.constant = banner.height;
    }
    else if (banner.position == FLBannerPositionBottom) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.staticMapBottomInentContraint.constant = -self.staticMap.height;
            self.collectionViewBottomIndentConstraint.constant = banner.height;
        }
        else {
            self.collectionViewBottomIndentConstraint.constant = self.staticMap.height + banner.height;
            self.staticMapBottomInentContraint.constant = banner.height;
        }
    }
}

@end
