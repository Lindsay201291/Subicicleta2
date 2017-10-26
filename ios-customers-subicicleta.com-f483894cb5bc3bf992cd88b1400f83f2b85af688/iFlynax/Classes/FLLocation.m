//
//  FLLocation.m
//  iFlynax
//
//  Created by Alex on 11/13/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLLocation.h"
#import "CCAlertView.h"

static NSString * const kLocationMyLastLocationKey = @"myLastLocation";
static NSString * const kLocationLatKey            = @"lat";
static NSString * const kLocationLngKey            = @"lng";

@interface FLLocation () {
	BOOL _startUpdating;
}

@property (nonatomic, strong) CLLocation *myLastLocation;
@end

@implementation FLLocation

+ (instancetype)sharedInstance {
	static FLLocation *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
		[_sharedInstance prepareLocationManager];

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *locationInfo = [defaults objectForKey:kLocationMyLastLocationKey];

		if (locationInfo != nil) {
			CLLocation *location = [[CLLocation alloc] initWithLatitude:[locationInfo[kLocationLatKey] doubleValue]
															  longitude:[locationInfo[kLocationLngKey] doubleValue]];
			_sharedInstance.myLastLocation = location;
		}
	});
	return _sharedInstance;
}

+ (void)startUpdatingLocationWithParams:(NSDictionary *)params
					  completionHandler:(FLCompletionHandler)completionHandler {
	[[FLLocation sharedInstance] startUpdatingLocationWithParams:params completionHandler:completionHandler];
}

- (void)prepareLocationManager {
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.distanceFilter = kCLDistanceFilterNone;
	_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
	_locationManager.delegate = self;
}

- (void)startUpdatingLocationWithParams:(NSDictionary *)params
					  completionHandler:(FLCompletionHandler)completionHandler {

	// iOS 8+ required Authorization
	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[_locationManager requestWhenInUseAuthorization];
		CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
		
		// If the status is denied or only granted for when in use, display an alert
		if (status == kCLAuthorizationStatusDenied) {
			CCAlertView *alert = [[CCAlertView alloc] initWithTitle:FLLocalizedString(@"alert_title_location_service_off")
															message:FLLocalizedString(@"alert_message_location_service_off")];
			[alert addButtonWithTitle:FLLocalizedString(@"button_cancel") block:nil];
			[alert addButtonWithTitle:FLLocalizedString(@"button_settings") block:^{
				// Send the user to the Settings for this app
				[[UIApplication sharedApplication] openURL:URLIFY(UIApplicationOpenSettingsURLString)];
			}];
			[alert show];
		}
	}

	// assign callback
	if (completionHandler != nil)
		_completionHandler = completionHandler;

	_startUpdating = YES;
	[_locationManager startUpdatingLocation];
}

- (CLLocation *)getMyLastLocation {
	if (_myLastLocation == nil)
		return [[CLLocation alloc] initWithLatitude:-33.8775547 longitude:151.1037054];
	return _myLastLocation;
}

#pragma mark - setters

- (void)setMyLastLocation:(CLLocation *)myLastLocation {
	_myLastLocation = myLastLocation;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *locationInfo = @{kLocationLatKey: [NSNumber numberWithDouble:myLastLocation.coordinate.latitude],
								   kLocationLngKey: [NSNumber numberWithDouble:myLastLocation.coordinate.longitude]};
	[defaults setObject:locationInfo forKey:kLocationMyLastLocationKey];
	[defaults synchronize];
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if (!_startUpdating)
		return;

	// update my last location
	self.myLastLocation = [locations lastObject];

	// stop updating
	[_locationManager stopUpdatingLocation];
	_startUpdating = NO;

	// invoke callback with location
	if (_completionHandler != nil)
		_completionHandler(self.myLastLocation, nil, nil);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[_locationManager stopUpdatingLocation];
	_startUpdating = NO;

	// invoke callback with errors
	if (_completionHandler != nil)
		_completionHandler(nil, nil, error);
}

@end
