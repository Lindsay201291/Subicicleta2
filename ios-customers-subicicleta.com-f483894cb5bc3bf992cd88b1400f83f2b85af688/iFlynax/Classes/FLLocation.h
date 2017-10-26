//
//  FLLocation.h
//  iFlynax
//
//  Created by Alex on 11/13/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^FLCompletionHandler)(CLLocation *location, NSString *address, NSError *error);

@interface FLLocation : NSObject <CLLocationManagerDelegate> {
	FLCompletionHandler _completionHandler;
}
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 *	Description
 *	@return return value description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 *	@return return value description
 */
- (CLLocation *)getMyLastLocation;

/**
 *	Description
 *	@param params            params description
 *	@param completionHandler completionHandler description
 */
+ (void)startUpdatingLocationWithParams:(NSDictionary *)params
					  completionHandler:(FLCompletionHandler)completionHandler;
@end
