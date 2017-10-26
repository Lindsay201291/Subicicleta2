//
//  FLMyAdShortDetailsModel.h
//  iFlynax
//
//  Created by Alex on 10/7/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLAdShortDetailsModel.h"

static NSString * const kFormLastStepForm     = @"form";
static NSString * const kFormLastStepCheckout = @"checkout";

typedef NS_ENUM(NSInteger, FLListingStatus) {
    FLListingStatusUnknown,
    FLListingStatusActive,
    FLListingStatusInActive,
    FLListingStatusPending,
    FLListingStatusIncomplete,
    FLListingStatusExpired
};

@interface FLMyAdShortDetailsModel : FLAdShortDetailsModel
@property (nonatomic, readonly) FLListingStatus status;
@property (nonatomic, readonly) BOOL paid;
@property (nonatomic, readonly) NSInteger views;
@property (nonatomic, readonly) NSInteger planId;
@property (nonatomic, readonly) NSInteger categoryId;

@property (nonatomic, copy, readonly) NSString *payDateString;
@property (nonatomic, copy, readonly) NSString *postedDateString;
@property (nonatomic, copy, readonly) NSString *featuredDateString;

@property (nonatomic, copy, readonly) NSString *featuredExpireString;
@property (nonatomic, copy, readonly) NSString *planExpireString;

@property (nonatomic, copy, readonly) NSString *statusString;
@property (nonatomic, copy, readonly) NSString *statusStringName;
@property (nonatomic, copy, readonly) NSString *subStatusString;

@property (nonatomic, copy, readonly) NSString *planName;
@property (nonatomic, copy, readonly) NSString *categoryName;

@property (nonatomic, copy, readonly) NSString *formLastStep;
@end
