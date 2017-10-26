//
//  FLStaticMap.m
//  iFlynax
//
//  Created by Alex on 4/30/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "FLStaticMap.h"
#import "FLLocation.h"

@interface FLStaticMap ()
@property (weak, nonatomic) IBOutlet GMSMapView *gMapView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@end

@implementation FLStaticMap

- (void)awakeFromNib {
    [super awakeFromNib];

	_gMapView.layer.shadowColor   = [UIColor blackColor].CGColor;
	_gMapView.layer.shadowOpacity = 0.35f;
	_gMapView.layer.shadowOffset  = CGSizeMake(0.0f, -2.0f);
	_gMapView.layer.masksToBounds = NO;

	UIBezierPath *staticMapBezierPath = [UIBezierPath bezierPathWithRect:_gMapView.bounds];
	_gMapView.layer.shadowPath = staticMapBezierPath.CGPath;

    _maskView.backgroundColor = FLHexColor(kColorBarTintColor);
}

- (void)updateUserLocationOnMap {

	[FLLocation startUpdatingLocationWithParams:nil
							  completionHandler:^(CLLocation *location, NSString *address, NSError *error) {
								  if (error == nil) {
                                      float mapZoom = FLTrueInt(FLConfigWithKey(kMapDefaultLocationZoomKey));

                                      GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                                              longitude:location.coordinate.longitude
                                                                                                   zoom:mapZoom];

                                      _gMapView.camera = camera;
                                      _gMapView.padding = UIEdgeInsetsMake(30.0, 0.0, 40.0, 0.0);

                                      // set my location marker
                                      GMSMarker *marker = [[GMSMarker alloc] init];
                                      marker.icon = [UIImage imageNamed:@"mylocation_marker"];
                                      marker.position = camera.target;
                                      marker.map = _gMapView;
								  }
							  }];

    _titleLabel.text = FLLocalizedString(@"screen_nearby_ads");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.onTap != nil) {
        self.onTap();
    }
}

@end
