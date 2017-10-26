//
//  FLRemoteNotifications.h
//  iFlynax
//
//  Created by Alex on 10/29/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLRemoteNotifications : NSObject

+ (instancetype)sharedInstance;

+ (void)registerDevice;
+ (void)unRegisterDevice;
+ (BOOL)isRegisteredForRemoteNotifications;

+ (void)sendDeviceTokenToAPI:(NSData *)token;

+ (NSString *)deviceTokenForRemoteNotifications;

+ (void)didReceiveRemoteNotification:(NSDictionary *)notification;
+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
