//
//  FLPlanModel.h
//  iFlynax
//
//  Created by Alex on 2/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kUnlimSymbolCode = @"\u221E";
static NSString * const kDefaultHexColor = @"e2e2e2";

typedef NS_ENUM(NSInteger, FLPlanMode) {
    FLPlanModeStandard = 1,
    FLPlanModeFeatured
};

typedef NS_ENUM(NSInteger, FLPlanType) {
    FLPlanTypeUnknown = 0,
    FLPlanTypeFeatured,
    FLPlanTypeListing,
    FLPlanTypePackage,
};

@interface FLPlanModel : NSObject <NSCopying>

@property (nonatomic, assign, readonly) NSInteger  pId;
@property (nonatomic, copy,   readonly) NSString   *key;
@property (nonatomic, copy,   readonly) NSString   *inAppKey;
@property (nonatomic, assign, readonly) FLPlanType type;
@property (nonatomic, copy,   readonly) NSString   *typeString;
@property (nonatomic, copy,   readonly) NSString   *typeShortName;
@property (nonatomic, copy,   readonly) NSString   *title;
@property (nonatomic, strong, readonly) UIColor    *color;
@property (nonatomic, copy,   readonly) NSString   *colorString;
@property (nonatomic, copy,   readonly) NSString   *localizedPrice;

@property (nonatomic, assign, readonly) NSInteger  imagesMax;
@property (nonatomic, copy,   readonly) NSString   *imagesMaxString;
@property (nonatomic, assign, readonly) NSInteger  videosMax;
@property (nonatomic, copy,   readonly) NSString   *videosMaxString;

@property (nonatomic, assign, readonly) BOOL       paymentIsRequired;
@property (nonatomic, assign, readonly) BOOL       advancedMode;
@property (nonatomic, assign, readonly) BOOL       imagesUnlim;
@property (nonatomic, assign, readonly) BOOL       videosUnlim;
@property (nonatomic, assign, readonly) BOOL       featured;

@property (nonatomic, assign, readonly) NSInteger  featuredListings;
@property (nonatomic, assign, readonly) NSInteger  featuredRemains;
@property (nonatomic, assign, readonly) NSInteger  standardListings;
@property (nonatomic, assign, readonly) NSInteger  standardRemains;

@property (nonatomic, assign, readonly) NSInteger  planPeriod;
@property (nonatomic, assign, readonly) NSInteger  planUsingId;

@property (nonatomic, assign, readonly) NSInteger  listingNumber;
@property (nonatomic, assign, readonly) NSInteger  listingPeriod;
@property (nonatomic, copy,   readonly) NSString   *listingPeriodString;
@property (nonatomic, assign, readonly) NSInteger  listingsRemains;
@property (nonatomic, assign, readonly) NSInteger  packageId;

@property (nonatomic, assign, readonly) NSInteger  planUsing;
@property (nonatomic, assign, readonly) NSInteger  planLimit;

// readWrite properties
@property (nonatomic, assign) CGFloat    price;
@property (nonatomic, copy  ) NSString   *currencyCode;
@property (nonatomic, copy  ) NSString   *currencySymbol;

@property (nonatomic, assign) FLPlanMode planMode;

/**
 *	Convert plan from dictionary to model
 *	@param plan - dictionary of plan
 *	@return model of plan
 */
+ (instancetype)fromDictionary:(NSDictionary *)plan;

/**
 *	Description
 *	@param zone zone description
 *	@return copy of this object
 */
- (instancetype)copyWithZone:(NSZone *)zone;

- (NSNumberFormatter *)priceFormatter;
@end
