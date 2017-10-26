//
//  FLMyAdShortDetailsModel.m
//  iFlynax
//
//  Created by Alex on 10/7/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLMyAdShortDetailsModel.h"

@implementation FLMyAdShortDetailsModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[FLMyAdShortDetailsModel alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [super initFromDictionary:data];
    if (self) {
        _payDateString        = FLCleanString(data[@"Pay_date"]);
        _postedDateString     = FLCleanString(data[@"Date"]);
        _featuredDateString   = FLCleanString(data[@"Featured_date"]);

        _featuredExpireString = FLCleanString(data[@"Featured_expire"]);
        _planExpireString     = FLCleanString(data[@"Plan_expire"]);

        _statusString         = FLCleanString(data[@"status"]);
        _statusStringName     = FLLocalizedString(F(@"status_%@", _statusString));
        _subStatusString      = FLCleanString(data[@"sub_status"]);
        _planId               = FLTrueInteger(data[@"plan_id"]);
        _planName             = FLCleanString(data[@"plan_name"]);
        _categoryId           = FLTrueInteger(data[@"category_id"]);
        _categoryName         = FLCleanString(data[@"category_name"]);
        _views                = FLTrueInteger(data[@"views"]);

        _status               = [self stringStatusToInt:_statusString];
        _formLastStep         = FLTrueString(data[@"last_step"]);
    }
    return self;
}

- (FLListingStatus)stringStatusToInt:(NSString *)stringStatus {
    if ([stringStatus isEqualToString:@"active"])
        return FLListingStatusActive;
    else if ([stringStatus isEqualToString:@"approval"])
        return FLListingStatusInActive;
    else if ([stringStatus isEqualToString:@"pending"])
        return FLListingStatusPending;
    else if ([stringStatus isEqualToString:@"incomplete"])
        return FLListingStatusIncomplete;
    else if ([stringStatus isEqualToString:@"expired"])
        return FLListingStatusExpired;
    return FLListingStatusUnknown;
}

//- (NSString *)description {
//    NSMutableString *string = [NSMutableString stringWithString:[super description]];
//
//    return string;
//}

@end
