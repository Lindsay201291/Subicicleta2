//
//  FLAdOnMapView.m
//  iFlynax
//
//  Created by Alex on 8/28/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAdOnMapView.h"
#import <GoogleMaps/GoogleMaps.h>
#import "FLLocation.h"
#import "CCActionSheet.h"

static NSURL *_buildMapsUrlWithScheme(NSString *urlMask, NSDictionary *target) {
    CLLocation *myLocation = [[FLLocation sharedInstance] getMyLastLocation];
    NSString *stringURL = [NSString stringWithFormat:urlMask,
                           myLocation.coordinate.latitude,
                           myLocation.coordinate.longitude,
                           [target[@"lat"] doubleValue],
                           [target[@"lng"] doubleValue]];
    
    return [NSURL URLWithString:stringURL];
}

@interface FLAdOnMapView () <GMSMapViewDelegate>

@end

@implementation FLAdOnMapView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = FLLocalizedString(@"screen_anuncio_en_mapa");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    float mapZoom = FLTrueInt(FLConfigWithKey(kMapDefaultLocationZoomKey));
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_location[@"lat"] doubleValue]
                                                            longitude:[_location[@"lng"] doubleValue]
                                                                 zoom:mapZoom];

    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    mapView.delegate = self;

    // set marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.layer.backgroundColor = [UIColor purpleColor].CGColor;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.position = camera.target;
    marker.map = mapView;

    if (_abilityToBuildRoute) {
        marker.snippet = FLLocalizedString(@"marker_drive_route");
        [FLLocation startUpdatingLocationWithParams:nil completionHandler:nil];
    }

    marker.title = FLCleanString(_location[@"title"]);

    if ([marker.title isEmpty]) {
        marker.title = FLLocalizedString(@"cargando");

        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:camera.target completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
            if (error == nil) {
                GMSAddress *address = response.firstResult;

                if (address && address.lines) {
                    marker.title = [address.lines componentsJoinedByString:@", "];
                }
            }
        }];
    }

    // appear marker
    mapView.selectedMarker = marker;

    self.view = mapView;
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = @"Ad on Map";
	[super viewDidAppear:animated];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if (!_abilityToBuildRoute)
        return;

    UIApplication *application = [UIApplication sharedApplication];
    NSMutableArray *appSchemes = [NSMutableArray array];

    [appSchemes addObject:@{@"name": FLLocalizedString(@"sheet_drive_route_item_apple"),
                            @"url": @"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f"}];

    if ([application canOpenURL:URLIFY(@"comgooglemaps://")]) {
        [appSchemes addObject:@{@"name": FLLocalizedString(@"sheet_drive_route_item_google"),
                                @"url": @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=transit"}];
    }
    if ([application canOpenURL:URLIFY(@"waze://")]) {
        [appSchemes addObject:@{@"name": FLLocalizedString(@"sheet_drive_route_item_waze"),
                                @"url": @"waze://?skip=%f%f&ll=%f,%f&navigate=yes"}];
    }
    if ([application canOpenURL:URLIFY(@"yandexmaps://")]) {
        [appSchemes addObject:@{@"name": FLLocalizedString(@"sheet_drive_route_item_yandex"),
                                @"url": @"yandexmaps://maps.yandex.ru/?rtext=%f,%f~%f,%f&rtt=mt"}];
    }

    if (appSchemes.count > 1) {
        CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:FLLocalizedString(@"sheet_drive_route_title")];

        [appSchemes enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger idx, BOOL *stop) {
            [sheet addButtonWithTitle:FLCleanString(entry[@"name"]) block:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application openURL:_buildMapsUrlWithScheme(entry[@"url"], _location)];
                });
            }];
        }];

        [sheet addCancelButtonWithTitle:FLLocalizedString(@"button_cancelar")];
        [sheet showFromRect:marker.iconView.frame inView:marker.map animated:YES];
    }
    else {
        NSDictionary *appleMaps = [appSchemes firstObject];
        [application openURL:_buildMapsUrlWithScheme(appleMaps[@"url"], _location)];
    }
}

@end
