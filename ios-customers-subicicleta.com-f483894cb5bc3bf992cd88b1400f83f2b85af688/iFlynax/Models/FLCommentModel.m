//
//  FLCommentModel.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/21/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLCommentModel.h"

static NSString * const kCommentTitleKey   = @"title";
static NSString * const kCommentBodyKey    = @"description";
static NSString * const kCommentAuthorKey  = @"author";
static NSString * const kCommentDateKey    = @"date";
static NSString * const kCommentRatingKey  = @"rating";
static NSString * const kCommentStatusKey  = @"status";

static NSString * const kCommentStatusPendingValue  = @"pending";
static NSString * const kCommentStatusActiveValue   = @"active";

@interface FLCommentModel ()
@property (nonatomic, copy) NSDictionary *data;
@end

@implementation FLCommentModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[self alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _data = data;
        
        _title  = FLCleanString(data[kCommentTitleKey]);
        _author = FLCleanString(data[kCommentAuthorKey]);
        _body   = FLCleanString(data[kCommentBodyKey]);
        _date   = FLCleanString(data[kCommentDateKey]);
        _rating = FLTrueInteger(data[kCommentRatingKey]);
        _status = [self statusFromString:FLCleanString(data[kCommentStatusKey])];
    }
    return self;
}

- (FLCommentStatus)statusFromString:(NSString *)statusString {
    if ([statusString isEqualToString:kCommentStatusActiveValue])
        return FLCommentStatusActive;
    else if ([statusString isEqualToString:kCommentStatusPendingValue])
        return FLCommentStatusPending;
    return  FLCommentStatusOther;
}

@end
