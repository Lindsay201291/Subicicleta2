//
//  FLViewController.m
//  iFlynax
//
//  Created by Alex on 4/7/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLViewController.h"
@import GoogleMobileAds;

@interface FLViewController () <REFrostedViewControllerDelegate>
@property (strong, nonatomic) NSDictionary *supportedScreens;
@property (strong, nonatomic) NSArray *availableAdMobs;
@property (strong, nonatomic) GADBannerView *gAdBannerView;
@property (nonatomic) BOOL relatedConstraintsUpdated;
@property (nonatomic) BOOL constraintsWithSizeClasses;
@end

@implementation FLViewController

- (GADBannerView *)gAdBannerView {
    if (!_gAdBannerView) {
        _gAdBannerView = [GADBannerView new];
        _gAdBannerView.adUnitID = _googleAd.unitID;
        _gAdBannerView.rootViewController = self;
    }
    return _gAdBannerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _relatedConstraintsUpdated = YES;
    _constraintsWithSizeClasses = NO;

    [self displayBannerIfNeeded];
}

- (void)displayBannerIfNeeded {
    if ([self bannerAvailableOnThisScreenAndExists] && !_gAdBannerView) {
        [self addBannerView];
        [self loadBannerRequest];
        [self addBannerViewConstraints];
        [self updateRelatedConstraints];
    }
}

- (NSDictionary *)supportedScreens {
    if (_supportedScreens == nil) {
        _supportedScreens = @{@"FLHomeView"                         : @(FLBannerPageHome),
                              @"FLRecentlyAdsRootView"              : @(FLBannerPageRecentryAdded),
                              @"FLRecentlyView"                     : @(FLBannerPageRecentryAdded),
                              @"FLBrowseView"                       : @(FLBannerPageBrowse),
                              @"FLFavoritesView"                    : @(FLBannerPageFavorites),
                              @"FLSearchRootView"                   : @(FLBannerPageSearch),
                              @"FLSearchView"                       : @(FLBannerPageSearch),
                              @"FLAdDetailsRootView"                : @(FLBannerPageAdDetaild),
                              @"FLAccountDetailsRootViewController" : @(FLBannerPageAccountDetails),
                              @"FLAccountTypeRootView"              : @(FLBannerPageAccountType),
                              @"FLSearchResultsVC"                  : @(FLBannerPageSearchResults),
                              @"FLAccountTypeListViewController"    : @(FLBannerPageAccountSearchResults),
                              @"FLCommentsView"                     : @(FLBannerPageComments)};
    }
    return _supportedScreens;
}

- (NSArray *)availableAdMobs {
    if (_availableAdMobs == nil) {
        _availableAdMobs = [FLCache objectWithKey:kCacheGoogleAdmobKey];
    }
    return _availableAdMobs;
}

- (BOOL)bannerAvailableOnThisScreenAndExists {
    if ([self.parentViewController isKindOfClass:UIPageViewController.class]) {
        return NO;
    }
    
    NSString *screen = NSStringFromClass(self.navigationController.visibleViewController.class);

    if (self.supportedScreens[screen] == nil) {
        return NO;
    }

    if (self.availableAdMobs == nil || self.availableAdMobs.count == 0) {
        return NO;
    }

    FLBannerPage bannerPage = FLTrueInteger(self.supportedScreens[screen]);

    for (NSDictionary *entry in self.availableAdMobs) {
        NSArray *admobPages = entry[@"pages"];

        if (admobPages.count && [admobPages indexOfObject:@(bannerPage)] != NSNotFound) {
            _googleAd = [FLGoogleAdModel fromDictionary:entry];
            break;
        }
    }

    if (_googleAd == nil) {
        return NO;
    }

    _constraintsWithSizeClasses = (bannerPage == FLBannerPageHome && _googleAd.position == FLBannerPositionBottom);
    
    return YES;
}

- (void)addBannerView {
    switch (_googleAd.position) {
        case FLBannerPositionTop:
            [self.view insertSubview:self.gAdBannerView atIndex:0];
            break;
        case FLBannerPositionBottom:
            [self.view addSubview:self.gAdBannerView];
            break;
    }
    [self.view bringSubviewToFront:self.gAdBannerView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_relatedConstraintsUpdated && _constraintsWithSizeClasses) {
        [self updateRelatedConstraints];
        _relatedConstraintsUpdated = NO;
    }
}

- (void)loadBannerRequest {
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID, kGoogleAdTestDeviceID];
    [self.gAdBannerView loadRequest:request];
}

- (void)updateNecessaryConstraintsForBannerView {
    //TODO: update constraints for some reason
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (_constraintsWithSizeClasses) {
        [self updateRelatedConstraints];
    }
}

#pragma mark - Navigation

- (void)frostedViewController:(REFrostedViewController *)frostedViewController
   willShowMenuViewController:(UIViewController *)menuViewController {
    [self.view endEditing:YES];
}


#pragma mark - Constraints

- (void)addBannerViewConstraints {
    
    self.gAdBannerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (_googleAd.position) {
        case FLBannerPositionTop:
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_gAdBannerView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.topLayoutGuide
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:0]];
            break;
        case FLBannerPositionBottom:
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_gAdBannerView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:0]];
            break;
    }
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_gAdBannerView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_gAdBannerView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    [_gAdBannerView addConstraint:[NSLayoutConstraint constraintWithItem:_gAdBannerView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:_googleAd.height]];
    
}

- (void)updateRelatedConstraints {
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        
        if (constraint.firstItem == self.gAdBannerView || constraint.secondItem == self.gAdBannerView)
            continue;

        if (_googleAd.position == FLBannerPositionTop) {
            if (constraint.firstItem == self.topLayoutGuide && constraint.firstAttribute == NSLayoutAttributeBottom) {
                constraint.constant -= _googleAd.height;
            }
            else if (constraint.secondItem == self.topLayoutGuide && constraint.secondAttribute == NSLayoutAttributeBottom) {
                constraint.constant += _googleAd.height;
            }
        }
        else if (_googleAd.position == FLBannerPositionBottom) {
            if (constraint.firstItem == self.bottomLayoutGuide && constraint.firstAttribute == NSLayoutAttributeTop) {
                constraint.constant += _googleAd.height;
            }
            else if (constraint.secondItem == self.bottomLayoutGuide && constraint.secondAttribute == NSLayoutAttributeTop) {
                constraint.constant -= _googleAd.height;
            }
        }
        
    }
}

@end
