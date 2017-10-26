//
//  FLAppDelegate.m
//  iFlynax
//
//  Created by Alex on 4/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAppDelegate.h"
#import <GoogleAnalytics/GAI.h>
#import <GoogleMaps/GoogleMaps.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "FLRemoteNotifications.h"
#import "FLPaymentHelper.h"
#import "PayPalMobile.h"
#import "FLStoreKit.h"
#import "FLAccount.h"
#import "iRate.h"

@implementation FLAppDelegate

+ (void)initialize {
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].verboseLogging = NO;
}

- (void)setupGoogleAnalitics {
	BOOL gaEnabled = [FLConfig boolWithKey:@"ga_enable"];
    NSString *gaTrakingId = [FLConfig stringWithKey:@"ga_traking_id"];

	if (!gaEnabled || [gaTrakingId isEmpty])
		return;

	// Optional: automatically send uncaught exceptions to Google Analytics.
	[GAI sharedInstance].trackUncaughtExceptions = YES;
	// Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
	[GAI sharedInstance].dispatchInterval = FLTrueDouble(FLConfigWithKey(@"ga_dispatch_interval")) ?: 120;
	// Optional: set Logger to VERBOSE for debug information.
	[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
	// Initialize tracker.
	[[GAI sharedInstance] trackerWithTrackingId:gaTrakingId];
}

- (void)setupGoogleMaps {
    NSString *gaAPIkey = [FLConfig stringWithKey:kGoogleMapAPIKey];

    // Prevent fatal error when the key is empty
    if ([gaAPIkey isEmpty]) {
        gaAPIkey = @"AIzaSyCeGxTS9yeR5E75Tjd8BsMn5TTnIxbDAEw"; // com.flynax.iFlynax
    }
    [GMSServices provideAPIKey:gaAPIkey];
}

- (void)setupInAppPurchases {
    if ([FLPaymentHelper inAppPurchasesIsAvailable] && [FLAccount isLogin]) {
        [FLStoreKit sharedManager];
    }
}

- (void)setupPayPal {
    if ([FLPaymentHelper payPalIsConfigured]) {
        NSString *clientId = [FLConfig stringWithKey:@"paypal_client_id"];
        NSDictionary *paypalEnvironments = @{PayPalEnvironmentProduction: clientId,
                                             PayPalEnvironmentSandbox   : clientId};
        [PayPalMobile initializeWithClientIdsForEnvironments:paypalEnvironments];
    }
}

- (void)setupFacebook {
    if ([FLConfig boolWithKey:@"facebook_login"]) {
        NSString *_appId = FLConfigWithKey(@"facebook_app_id");

        // Prevent a fatal error (must be same as in info.list)
        if (![_appId isEqualToString:kFacebookAppID]) {
            _appId = kFacebookAppID;
        }

        [FBSDKSettings setAppID:_appId];
        [FBSDKSettings setDisplayName:FLLocalizedString(@"facebook_display_name")];
    }
}

- (void)updateVersionPreference {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *_version = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *_build   = [mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *versionPreference = [NSString stringWithFormat:@"%@ (build %@)", _version, _build];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:versionPreference forKey:@"version_preference"];
    [defaults synchronize];
}

- (void)setupAdditionalAppServices {
    // prepare google analitics
    [self setupGoogleAnalitics];
    
    // prepare Google Maps
    [self setupGoogleMaps];
    
    // prepare In-App Purchases
    [self setupInAppPurchases];
    
    // preprare PayPal
    [self setupPayPal];
    
    // prepare Facebook
    [self setupFacebook];
}

#pragma mark - Application delegates

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

	// customize FLProgressHUD
    [FLProgressHUD customize];

    // update app version in a general device settings
    [self updateVersionPreference];

    // clear all previos stored data
    [FLAppSession clearAll];

    // required for Labeled Solution
    if ([FLUserDefaults appPointedToDomain]) {
        [FLCache prepareGlobalAppCache];

        [self setupAdditionalAppServices];

        // possible remote notifications
        if (launchOptions != nil && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [FLRemoteNotifications didFinishLaunchingWithOptions:launchOptions];
            });
        }
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [flynaxAPIClient cancelAllTasks];
}

#pragma mark - Remote Notifications

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FLRemoteNotifications sendDeviceTokenToAPI:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification {
    [FLRemoteNotifications didReceiveRemoteNotification:notification];
}

@end
