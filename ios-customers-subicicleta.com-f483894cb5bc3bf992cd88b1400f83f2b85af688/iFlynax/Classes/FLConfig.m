//
//  FLConfig.m
//  iFlynax
//
//  Created by Alex on 5/12/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLConfig.h"

@implementation FLConfig

+ (instancetype)sharedInstance {
	static FLConfig *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	return _sharedInstance;
}

+ (BOOL)boolWithKey:(NSString *)key {
	return FLTrueBool([[FLConfig sharedInstance] withKey:key]);
}

+ (NSInteger)integerWithKey:(NSString *)key {
    return FLTrueInteger([[FLConfig sharedInstance] withKey:key]);
}

+ (NSString *)stringWithKey:(NSString *)key {
    return FLCleanString([[FLConfig sharedInstance] withKey:key]);
}

+ (id)withKey:(NSString *)key {
	return [[FLConfig sharedInstance] withKey:key];
}

#pragma mark - Instance methods

- (id)withKey:(NSString *)key {
	NSDictionary *configs = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheConfigsKey];
    
	if (configs != nil && configs[key] != nil) {
		return configs[key];
	}
	return nil;
}

+ (NSInteger)displayListingsNumberPerPage {
    return [FLConfig integerWithKey:@"grid_listings_number"] ?: 15;
}

@end
