//
//  FLNearbyAdsView.m
//  iFlynax
//
//  Created by Alex on 4/30/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLNearbyAdsView.h"
#import "REFrostedViewController.h"
#import "FLAdShortDetailsModel.h"

#import "FLLocation.h"
#import "GClusterManager.h"
#import "GDefaultClusterRenderer.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"

#import "FLListingFormModel.h"
#import "FLTableViewManager.h"
#import "FLKeyboardHandler.h"
#import "FLFieldModel.h"

/*
@interface FLMarkerContentView : UIView
+ (instancetype)withSize:(CGSize)size data:(NSDictionary *)data;
@end

@implementation FLMarkerContentView

+ (instancetype)withSize:(CGSize)size data:(NSDictionary *)data {
    return [[FLMarkerContentView alloc] initWithSize:size data:data];
}

- (instancetype)initWithSize:(CGSize)size data:(NSDictionary *)data {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        self.backgroundColor = [UIColor purpleColor];
        NSLog(@"data: %@", data);
    }
    return self;
}

@end
*/

static NSString * const kColorBarButton = @"666666";

@interface Spot : NSObject <GClusterItem>
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) GMSMarker *marker;
@end

@implementation Spot
- (CLLocationCoordinate2D)position {
    return self.location;
}
@end

////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, FLNearbyAdsModeView) {
    FLNearbyAdsModeViewMap = 1,
    FLNearbyAdsModeViewList,
    FLNearbyAdsModeViewFilter
};

static NSString * const kTimerUserInfoPositionKey = @"position";

@interface FLNearbyAdsView () <GMSMapViewDelegate, RETableViewManagerDelegate, FLKeyboardHandlerDelegate> {
    GMSMapView *_gMapView;
    GClusterManager *_clusterManager;
    UIColor *barButtonTintColor;
    UIColor *barButtonSelectedTintColor;
}

@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic, strong) NSMutableArray *markersOnMap;
@property (nonatomic, strong) NSURLSessionDataTask *mapTask;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapSettingsBtn;

@property (assign, nonatomic) FLNearbyAdsModeView adsModeView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbarView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterViewButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *listViewButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapViewButton;

@property (copy, nonatomic) NSDictionary *apiParams;
@property (nonatomic, strong) NSTimer *timer;

@property (strong, nonatomic) FLTableViewManager *manager;
@property (strong, nonatomic) FLKeyboardHandler  *keyboardHandler;
@end

@implementation FLNearbyAdsView

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = FLLocalizedString(@"screen_nearby_ads");

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    float mapZoom = FLTrueInt(FLConfigWithKey(kMapDefaultLocationZoomKey));
	CLLocationCoordinate2D location = [[FLLocation sharedInstance] getMyLastLocation].coordinate;

	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                            longitude:location.longitude
                                                                 zoom:mapZoom];
	_gMapView = _mapView;
	_gMapView.settings.myLocationButton = YES;
	_gMapView.settings.compassButton = YES;
    _gMapView.camera = camera;

    self.markersOnMap = [NSMutableArray array];
    _clusterManager = [GClusterManager managerWithMapView:_gMapView
                                                algorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]
                                                 renderer:[[GDefaultClusterRenderer alloc] initWithMapView:_gMapView]];

    _gMapView.delegate = _clusterManager;
    _clusterManager.delegate = self;

	dispatch_async(dispatch_get_main_queue(), ^{
		_gMapView.myLocationEnabled = YES;
	});
    
    self.tableView.alpha = 1;
    
    self.blankSlate.title = FLLocalizedString(@"blankSlate_nearbyAds_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_nearbyAds_message");
    
    barButtonTintColor = FLHexColor(kColorBarButton);
    barButtonSelectedTintColor = FLHexColor(kColorThemeGlobal);
    
    self.adsModeView = FLNearbyAdsModeViewMap;
    self.navigationItem.rightBarButtonItem = nil;

    // Filter initialization
    NSArray *nearbyAdsFilterFields = [FLCache objectWithKey:kCacheNearbyAdsSFormsKey];
    if (nearbyAdsFilterFields.count) {
        self.manager = [FLTableViewManager withTableView:_filterTableView];

        _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:_filterTableView];
        _keyboardHandler.delegate = self;
        _keyboardHandler.autoHideEnable = NO;

        _filterTableView.backgroundColor = FLHexColor(kColorBackgroundColor);
        _filterView.backgroundColor = FLHexColor(kColorBackgroundColor);

        // build form
        RETableViewSection *section = [RETableViewSection section];
        [self.manager addSection:section];
        
        for (NSDictionary *fieldDict in nearbyAdsFilterFields) {
            FLFieldModel *field = [FLFieldModel fromDictionary:fieldDict];
            RETableViewItem *item = nil;
            
            if (field.type == FLFieldTypeText) {
                item = [FLFieldText fromModel:field];
            }
            else if (field.type == FLFieldTypeSelect) {
                item = [FLFieldSelect fromModel:field tableView:_filterTableView];
            }
            else if (field.type == FLFieldTypeBool) {
                item = [FLFieldBool fromModel:field];
            }
            else if (field.type == FLFieldTypeDate) {
                item = [FLFieldDate fromModel:field];
            }
            else if (field.type == FLFieldTypeNumber) {
                item = [FLFieldNumber fromModel:field];
            }
            else if (field.type == FLFieldTypeTextarea) {
                item = [FLFieldTextArea fromModel:field];
            }
            else if (field.type == FLFieldTypeMixed ||
                     field.type == FLFieldTypePrice)
            {
                item = [FLFieldMixed fromModel:field];
            }
            else if (field.type == FLFieldTypeRadio) {
                item = [FLFieldRadio fromModel:field tableView:_filterTableView];
            }
            else if (field.type == FLFieldTypePhone) {
                item = [FLFieldPhone fromModel:field];
            }
            else if (field.type == FLFieldTypeAccept) {
                item = [FLFieldAccept fromModel:field parentVC:self];
            }
            else if (field.type == FLFieldTypeCheckbox) {
                item = [FLFieldCheckbox fromModel:field parentVC:self];
            }
            else {
                // skip another field types. (like: image,file)
                continue;
            }
            [section addItem:item];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [_filterTableView reloadData];
        });
    }
    else {
        // TODO: implement it by another way.
        NSMutableArray *_items = [_toolbarView.items mutableCopy];
        [_items removeObject:_filterViewButton];
        [_items removeObjectAtIndex:0];
        [_toolbarView setItems:_items];
    }
}

- (void)dealloc {
    [_keyboardHandler unRegisterNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = FLLocalizedString(@"screen_nearby_ads");
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
    [self.markersOnMap removeAllObjects];
    [_gMapView clear];
}

#pragma mark - Setters

- (void)setAdsModeView:(FLNearbyAdsModeView)adsModeView {
    if (_adsModeView != adsModeView) {
        
        self.filterView.hidden = adsModeView != FLNearbyAdsModeViewFilter;
        self.listTableView.hidden   = adsModeView != FLNearbyAdsModeViewList;
        self.mapView.hidden         = adsModeView != FLNearbyAdsModeViewMap;
        
        self.filterViewButton.tintColor = adsModeView == FLNearbyAdsModeViewFilter ? barButtonSelectedTintColor : barButtonTintColor;
        self.listViewButton.tintColor   = adsModeView == FLNearbyAdsModeViewList   ? barButtonSelectedTintColor : barButtonTintColor;
        self.mapViewButton.tintColor    = adsModeView == FLNearbyAdsModeViewMap    ? barButtonSelectedTintColor : barButtonTintColor;
        
        if (adsModeView == FLNearbyAdsModeViewList) {
             [self.tableView reloadData];
        }
        
        _adsModeView = adsModeView;
    }
}

- (void)timerFireMethod:(NSTimer *)timer {
    if (timer.isValid) {
        [self fetchListingsInsidePosition:timer.userInfo[kTimerUserInfoPositionKey]];
    }
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (_timer != nil && _timer.isValid) {
        if (_mapTask.state != NSURLSessionTaskStateCompleted) {
            [_mapTask cancel];
        }
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(timerFireMethod:)
                                            userInfo:@{kTimerUserInfoPositionKey: position} repeats:NO];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (marker.userData != nil && [marker.userData isEqual:kGClusterMarker]) {
        float zoom = _gMapView.camera.zoom + 1;

        // if max zoom then swap panel to list view
        if (zoom > 21) {
            self.adsModeView = FLNearbyAdsModeViewList;
            return NO;
        }

        GMSCameraPosition *clusterCamera = [GMSCameraPosition cameraWithLatitude:marker.position.latitude
                                                                       longitude:marker.position.longitude
                                                                            zoom:zoom];
        [_gMapView animateToCameraPosition:clusterCamera];

        return YES;
    }
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if (marker.userData != nil) {
        FLAdDetailsRootView *listingDetails = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardadDetailsRootView];
        listingDetails.shortDetails = marker.userData;
        [self.navigationController pushViewController:listingDetails animated:YES];
    }
}

- (IBAction)mapSettingsBtnDidTap:(UIBarButtonItem *)sender {
    NSLog(@"%s", __FUNCTION__);
}

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
//    return [FLMarkerContentView withSize:CGSizeMake(200, 150) data:marker.userData];
//}

#pragma mark - Actions

- (void)filterBtnDidTap {
    if ([self.manager isValidForm]) {
        NSLog(@"self.manager.formValues: %@", self.manager.formValues);
    }
}

- (IBAction)viewChangeAction:(UIBarButtonItem *)button {
    self.adsModeView = button == _filterViewButton ? FLNearbyAdsModeViewFilter : button == _listViewButton ? FLNearbyAdsModeViewList : FLNearbyAdsModeViewMap;
}


#pragma mark -

- (void)fetchListingsInsidePosition:(GMSCameraPosition *)position {
    
    GMSCoordinateBounds *gMapBounds = [[GMSCoordinateBounds alloc] initWithRegion:_gMapView.projection.visibleRegion];

    _apiParams = @{@"cmd"          : kApiItemRequests_getListingsByLatLng,
                   @"centerLat"    : @(position.target.latitude),
                   @"centerLng"    : @(position.target.longitude),
                   @"northEastLat" : @(gMapBounds.northEast.latitude),
                   @"northEastLng" : @(gMapBounds.northEast.longitude),
                   @"southWestLat" : @(gMapBounds.southWest.latitude),
                   @"southWestLng" : @(gMapBounds.southWest.longitude)};
    
    [self.entries removeAllObjects];
    
    _mapTask = [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:_apiParams
                      completion:^(NSDictionary *response, NSError *error) {
                          
                          if (error == nil) {
                              if ([response isKindOfClass:NSDictionary.class] && response[@"calc"] != nil) {
                                  int adsCount = [response[@"calc"] intValue];
                                  
                                  if (adsCount && response[@"listings"] != nil) {
                                      NSArray *listings = response[@"listings"];
                                    
                                      [self.entries addObjectsFromArray:listings];
                                      
                                      [listings enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger idx, BOOL *stop) {
                                          FLAdShortDetailsModel *listing = [FLAdShortDetailsModel fromDictionary:entry];
                                          
                                          NSInteger markedSpotIndex = [_markersOnMap indexOfObject:@(listing.lId)];
                                          if (markedSpotIndex != NSNotFound) {
                                              return;
                                          }
                                          
                                          CLLocationCoordinate2D position;
                                          position.latitude = [listing.location[@"lat"] doubleValue];
                                          position.longitude = [listing.location[@"lng"] doubleValue];

                                          Spot *spot = [[Spot alloc] init];
                                          spot.location = position;
                                          spot.marker = [GMSMarker markerWithPosition:position];
                                          spot.marker.appearAnimation = kGMSMarkerAnimationPop;
                                          spot.marker.title = listing.title;
                                          spot.marker.snippet = listing.subTitle;
                                          spot.marker.userData = listing;
                                          [_clusterManager addItem:spot];

                                          // exclude the listing id
                                          NSNumber *excludeId = [NSNumber numberWithInteger:listing.lId];
                                          [self.markersOnMap addObject:excludeId];
                                          
                                      }];

                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [_listTableView reloadData];
                                          [_clusterManager cluster];
                                      });
                                  }
                              }
                          }
                          else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_getListingsByLatLng];
                      }];
}

- (void)refreshData {
    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:_apiParams
                      completion:^(NSDictionary *response, NSError *error) {
                          if (error == nil) {
                              if ([response isKindOfClass:NSDictionary.class] && response[@"calc"] != nil) {
                                  int adsCount = [response[@"calc"] intValue];

                                  [self.entries removeAllObjects];

                                  if (adsCount && response[@"listings"] != nil) {
                                      NSArray *listings = response[@"listings"];
                                      [self.entries addObjectsFromArray:listings];
                                  }
                                  
                              }

                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.tableView reloadData];
                                  [self.refreshControl endRefreshing];
                              });
                          }
                          else {
                              [FLDebug showAdaptedError:error apiItem:kApiItemRequests_getListingsByLatLng];
                          }
                          self.tableView.scrollEnabled = YES;
                      }];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
