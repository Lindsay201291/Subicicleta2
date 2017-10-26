//
//  FLRemoteNotificationModel.h
//  iFlynax
//
//  Created by Alex on 4/12/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kNotifyApsKey    = @"aps";
static NSString * const kNotifyInfoKey   = @"info";
static NSString * const kNotifyAlertKey  = @"alert";
static NSString * const kNotifyActionKey = @"action";
static NSString * const kNotifyBadgeKey  = @"badge";
static NSString * const kNotifySoundKey  = @"sound";

typedef NS_ENUM(NSInteger, FLRemoteNotificationAction) {
    FLRemoteNotificationActionSavedSearch = 1,
    FLRemoteNotificationActionMessages    = 2,
    FLRemoteNotificationActionComments    = 3,
    FLRemoteNotificationActionNews        = 4
};

@interface FLRemoteNotificationModel : NSObject
@property (strong, nonatomic, readonly) NSDictionary *info;
@property (assign, nonatomic, readonly) FLRemoteNotificationAction action;
@property (assign, nonatomic, readonly) NSInteger badge;
@property (copy, nonatomic, readonly) NSString *alert;
@property (copy, nonatomic, readonly) NSString *sound;

+ (instancetype)fromDictionary:(NSDictionary *)data;

- (instancetype)initFromDictionary:(NSDictionary *)data;
@end
