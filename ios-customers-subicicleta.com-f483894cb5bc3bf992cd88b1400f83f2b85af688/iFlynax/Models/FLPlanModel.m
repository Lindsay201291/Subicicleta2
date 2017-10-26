//
//  FLPlanModel.m
//  iFlynax
//
//  Created by Alex on 2/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLPlanModel.h"

@interface FLPlanModel () {
    NSDictionary *_planDictionary;
}
@end

@implementation FLPlanModel

+ (instancetype)fromDictionary:(NSDictionary *)plan {
    return [[FLPlanModel alloc] initFromDictionary:plan];
}

- (instancetype)initFromDictionary:(NSDictionary *)plan {
    self = [super init];
    if (self) {
        _pId                 = FLTrueInteger(plan[@"ID"]);
        _key                 = FLCleanString(plan[@"Key"]);
        _inAppKey            = FLCleanString(plan[@"inAppKey"]);
        _typeString          = FLCleanString(plan[@"Type"]);
        _type                = [self planTypeStringToInteger:_typeString];
        _typeShortName       = FLCleanString(plan[@"typeShortName"]);
        _title               = FLCleanString(plan[@"name"]);
        _colorString         = FLCleanString(plan[@"Color"]);

        if ([_colorString isEmpty]) {
            _colorString = kDefaultHexColor;
        }
        _color               = [UIColor hexColor:_colorString];

        _price               = FLTrueFloat(plan[@"Price"]);
        _currencyCode        = FLTrueString(plan[@"currencyCode"]);

        _advancedMode        = FLTrueBool(plan[@"Advanced_mode"]);
        _featured            = (FLTrueBool(plan[@"Featured"]) || _type == FLPlanTypeFeatured);
        _planMode            = _featured ? FLPlanModeFeatured : FLPlanModeStandard;

        _imagesUnlim         = FLTrueBool(plan[@"Image_unlim"]);
        _videosUnlim         = FLTrueBool(plan[@"Video_unlim"]);
        _imagesMax           = _imagesUnlim ? 999 : FLTrueInteger(plan[@"Image"]);
        _videosMax           = _videosUnlim ? 999 : FLTrueInteger(plan[@"Video"]);

        _featuredListings    = FLTrueInteger(plan[@"Featured_listings"]);
        _featuredRemains     = FLTrueInteger(plan[@"Featured_remains"]);
        _standardListings    = FLTrueInteger(plan[@"Standard_listings"]);
        _standardRemains     = FLTrueInteger(plan[@"Standard_remains"]);

        _planPeriod          = FLTrueInteger(plan[@"Plan_period"]);
        _planUsing           = FLTrueInteger(plan[@"Using"]);
        _planUsingId         = FLTrueInteger(plan[@"Plan_using_ID"]);
        _listingNumber       = FLTrueInteger(plan[@"Listing_number"]);
        _listingPeriod       = FLTrueInteger(plan[@"Listing_period"]);
        _listingsRemains     = FLTrueInteger(plan[@"Listings_remains"]);
        _packageId           = FLTrueInteger(plan[@"Package_ID"]);
        _planLimit           = FLTrueInteger(plan[@"Limit"]);

        _imagesMaxString     = _imagesUnlim ? kUnlimSymbolCode : FLTrueString(@(_imagesMax));
        _videosMaxString     = _videosUnlim ? kUnlimSymbolCode : FLTrueString(@(_videosMax));
        _listingPeriodString = _listingPeriod
            ? FLLocalizedStringReplace(@"listing_period_days", @"{days}", FLTrueString(@(_listingPeriod)))
            : kUnlimSymbolCode;

        // make localized price with locale
        [self updateLocalizedPrice];

        // collect to future purpose. (@see copyWithZone)
        _planDictionary = plan;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    FLPlanModel *model = [[FLPlanModel alloc] initFromDictionary:_planDictionary];
    model.price = self.price;
    model.currencyCode = self.currencyCode;
    model.currencySymbol = self.currencySymbol;

    return model;
}

- (FLPlanType)planTypeStringToInteger:(NSString *)typeString {
    if ([typeString isEqualToString:@"listing"])
        return FLPlanTypeListing;
    else if ([typeString isEqualToString:@"featured"])
        return FLPlanTypeFeatured;
    else if ([typeString isEqualToString:@"package"])
        return FLPlanTypePackage;
    return FLPlanTypeUnknown;
}

- (void)setCurrencyCode:(NSString *)currencyCode {
    _currencyCode = currencyCode;
    [self updateLocalizedPrice];
}

- (BOOL)planOwned {
    return _packageId && _listingsRemains > 0;
}

- (BOOL)paymentIsRequired {
    return (_price > 0 && ![self planOwned]);
}

- (void)updateLocalizedPrice {
    if ([self planOwned]) {
        _localizedPrice = FLLocalizedString(@"available_package");
    }
    else if (_price == 0) {
        _localizedPrice = FLLocalizedString(@"free");
    }
    else if ([self paymentIsRequired]) {
        NSNumberFormatter *formatter = [self priceFormatter];
        _localizedPrice = [formatter stringFromNumber:@(_price)];
        _currencySymbol = [formatter.locale objectForKey:NSLocaleCurrencySymbol];
    }
}

- (NSNumberFormatter *)priceFormatter {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle  = kCFNumberFormatterCurrencyStyle;
    formatter.locale = [FLUtilities localeByCurrencyCode:_currencyCode];
    return formatter;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];

    [string appendFormat:@"pId: %d\n", (int)self.pId];
    [string appendFormat:@"key: %@\n", self.key];
    [string appendFormat:@"type: %@\n", self.typeString];
    [string appendFormat:@"title: %@\n", self.title];
    [string appendFormat:@"color: #%@\n", self.color];

    [string appendFormat:@"imagesMax: %d\n", (int)self.imagesMax];
    [string appendFormat:@"videosMax: %d\n", (int)self.videosMax];

    [string appendFormat:@"advancedMode: %@\n", self.advancedMode ? @"YES" : @"NO"];
    [string appendFormat:@"imagesUnlim: %@\n",  self.imagesUnlim  ? @"YES" : @"NO"];
    [string appendFormat:@"videosUnlim: %@\n",  self.videosUnlim  ? @"YES" : @"NO"];
    [string appendFormat:@"featured: %@\n",     self.featured     ? @"YES" : @"NO"];

    [string appendFormat:@"featuredListings: %d\n", (int)self.featuredListings];
    [string appendFormat:@"featuredRemains: %d\n",  (int)self.featuredRemains];
    [string appendFormat:@"standardListings: %d\n", (int)self.standardListings];
    [string appendFormat:@"standardRemains: %d\n",  (int)self.standardRemains];

    [string appendFormat:@"planPeriod: %d\n",  (int)self.planPeriod];
    [string appendFormat:@"planUsingId: %d\n", (int)self.planUsingId];
    [string appendFormat:@"listingNumber: %d\n",  (int)self.listingNumber];
    [string appendFormat:@"listingPeriod: %d\n", (int)self.listingPeriod];
    [string appendFormat:@"listingsRemains: %d\n",  (int)self.listingsRemains];

    [string appendFormat:@"planMode: %@\n",  self.planMode == FLPlanModeStandard  ? @"Standard" : @"Featured"];

    return string;
}

@end
