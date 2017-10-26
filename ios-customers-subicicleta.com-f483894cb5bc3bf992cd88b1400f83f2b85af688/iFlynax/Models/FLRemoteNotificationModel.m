//
//  FLRemoteNotificationModel.m
//  iFlynax
//
//  Created by Alex on 4/12/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLRemoteNotificationModel.h"

static NSString *_stringAction(FLRemoteNotificationAction action) {
    switch (action) {
        case FLRemoteNotificationActionSavedSearch:
            return @"SavedSearch";
        case FLRemoteNotificationActionMessages:
            return @"Messages";
        case FLRemoteNotificationActionComments:
            return @"Comments";
        case FLRemoteNotificationActionNews:
            return @"News";
    }
    return @"Undefined";
}

@implementation FLRemoteNotificationModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[self alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _info = data[kNotifyApsKey][kNotifyInfoKey];

        _action = FLTrueInteger(data[kNotifyActionKey]);
        _badge  = FLTrueInteger(data[kNotifyBadgeKey]);
        _alert  = FLTrueString(data[kNotifyAlertKey]);
        _sound  = FLTrueString(data[kNotifySoundKey]);
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:[super description]];

    [string appendString:@"\n"];
    [string appendFormat:@"action: %@\n", _stringAction(_action)];
    [string appendFormat:@"alert: %@\n", _alert];
    [string appendFormat:@"sound: %@\n", _sound];
    [string appendFormat:@"badge: %@\n", @(_badge)];

    return string;
}

@end
