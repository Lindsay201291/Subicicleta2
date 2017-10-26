//
//  FLCache.m
//  iFlynax
//
//  Created by Alex on 5/12/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLCache.h"
#import "FLConfig.h"
#import "FLLang.h"

static NSString * const kDefaultLangCodeKey = @"lang";

@implementation FLCache

+ (instancetype)sharedInstance {
	static FLCache *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	return _sharedInstance;
}

#pragma mark - public methods

+ (void)prepareGlobalAppCache {
	[[FLCache sharedInstance] prepareCache];
}

+ (void)refreshAppCache {
	[[FLCache sharedInstance] refreshAppCache];
}

+ (id)objectWithKey:(NSString *)key {
    return [[FLCache sharedInstance] objectWithKey:key];
}

#pragma mark - private methods

- (id)objectWithKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)prepareCache {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *lastCacheUpdate = [defaults objectForKey:kLastCacheUpdateKey];

	if (kForceLoadCache || lastCacheUpdate == nil || -[lastCacheUpdate timeIntervalSinceNow] > kDefaultRefreshCacheInterval) {
		NSDictionary *appCache = [self loadCacheFromWebsite];

		if (appCache != nil && [appCache isKindOfClass:NSDictionary.class]) {
			// configs
			if (appCache[kCacheConfigsKey] != nil) {
				[defaults setObject:appCache[kCacheConfigsKey] forKey:kCacheConfigsKey];
			}

			// listing types
			if (appCache[kCacheListingTypesKey] != nil) {
				[defaults setObject:appCache[kCacheListingTypesKey] forKey:kCacheListingTypesKey];
			}

            // categories 1level for each listing type
            if (appCache[kCacheCategoriesOneLevel] != nil) {
                [defaults setObject:appCache[kCacheCategoriesOneLevel] forKey:kCacheCategoriesOneLevel];
            }

			// account types
			if (appCache[kCacheAccountTypesKey] != nil) {
				[defaults setObject:appCache[kCacheAccountTypesKey] forKey:kCacheAccountTypesKey];
			}

			// languages
			if (appCache[kCacheLanguagesKey] != nil) {
				[defaults setObject:appCache[kCacheLanguagesKey] forKey:kCacheLanguagesKey];
			}

			// lang keys
			if (appCache[kCacheLangKeysKey] != nil) {
				for (NSString *code in appCache[kCacheLangKeysKey]) {
					NSString *customKey = F(@"%@%@", kLangKeysKeyPrefix, code);
					[defaults setObject:appCache[kCacheLangKeysKey][code] forKey:customKey];
				}
			}

            // set app language if necessary
            if (![defaults valueForKey:kDefaultKeyCurrentLanguage]) {
                NSString *defaultLanguageCode = appCache[kCacheConfigsKey][kDefaultLangCodeKey];

                if (kFeatureDefaultLanguageBasedOnDeviceLanguage && appCache[kCacheLanguagesKey] != nil) {
                    NSString *devicePreferredLanguage = [[NSLocale preferredLanguages] firstObject];
                    // Truncate some codes like: ar-US to ar
                    NSString *deviceLanguageCode = [devicePreferredLanguage substringWithRange:NSMakeRange(0, 2)];

                    if (appCache[kCacheLanguagesKey][deviceLanguageCode] != nil) {
                        defaultLanguageCode = deviceLanguageCode;
                    }
                }
                [defaults setValue:defaultLanguageCode forKey:kDefaultKeyCurrentLanguage];
            }

            // ads for home screen
            if (appCache[kCacheHomeScreenAdsKey] != nil) {
                [defaults setObject:appCache[kCacheHomeScreenAdsKey] forKey:kCacheHomeScreenAdsKey];
            }

            // Google AdMob's
            if (appCache[kCacheGoogleAdmobKey] != nil) {
                [defaults setObject:appCache[kCacheGoogleAdmobKey] forKey:kCacheGoogleAdmobKey];
            }

            // listing fields
            if (appCache[kCacheListingFieldsKey] != nil) {
                [defaults setObject:appCache[kCacheListingFieldsKey] forKey:kCacheListingFieldsKey];
            }

            // account fields
            if (appCache[kCacheAccountFieldsKey] != nil) {
                [defaults setObject:appCache[kCacheAccountFieldsKey] forKey:kCacheAccountFieldsKey];
            }

            // search forms
            if (appCache[kCacheSearchFormsKey] != nil) {
                [defaults setObject:appCache[kCacheSearchFormsKey] forKey:kCacheSearchFormsKey];
            }

			// account search forms
			if (appCache[kCacheAccountSearchFormsKey] != nil) {
				[defaults setObject:appCache[kCacheAccountSearchFormsKey] forKey:kCacheAccountSearchFormsKey];
			}

            // nearby ads search form
            if (appCache[kCacheNearbyAdsSFormsKey] != nil) {
                [defaults setObject:appCache[kCacheNearbyAdsSFormsKey] forKey:kCacheNearbyAdsSFormsKey];
            }

			// update last cache fetch time
			[defaults setObject:[NSDate date] forKey:kLastCacheUpdateKey];
			[defaults synchronize];

            // Refresh and apply selected localization
            [FLLang refresh];
		}
	}
}

- (NSDictionary *)loadCacheFromWebsite {
    NSString *apiDestination = [flynaxAPIClient sharedInstance].apiDestination;
    NSString *queryArgs = [flynaxAPIClient httpBuildUrlForItem:kApiItemCache withParameters:nil];
	NSString *cacheUrlString = [NSString stringWithFormat:@"%@?%@", apiDestination, queryArgs];

    if (!URLIFY(cacheUrlString)) {
		return nil;
    }

	NSData *response = [NSData dataWithContentsOfURL:URLIFY(cacheUrlString)];

	if (response != nil) {
		NSError *jsonError = nil;
		NSDictionary *appCache = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonError];

		if (jsonError == nil) {
			return appCache;
		}
	}
	return nil;
}

- (void)refreshAppCache {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:nil forKey:kLastCacheUpdateKey];
	[defaults synchronize];

	// force load cache
	[self prepareCache];
}

@end
