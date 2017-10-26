//
//  FLListingType.m
//  iFlynax
//
//  Created by Alex on 2/24/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingTypeModel.h"

@implementation FLListingTypeModel

+ (instancetype)fromDictionary:(NSDictionary *)listingType {
    return [[FLListingTypeModel alloc] initFromDictionary:listingType];
}

- (instancetype)initFromDictionary:(NSDictionary *)listingType {
    self = [super init];
    if (self) {
        _icon     = FLCleanString(listingType[@"icon"]);
        _key      = FLCleanString(listingType[@"key"]);
        _name     = FLCleanString(listingType[@"name"]);
        _page     = FLTrueBool(listingType[@"page"]);
        _photo    = FLTrueBool(listingType[@"photo"]);
        _search   = FLTrueBool(listingType[@"search"]);
        _video    = FLTrueBool(listingType[@"video"]);
        _position = FLTrueInteger(listingType[@"position"]);

        _categoriesSortBy = FLCleanString(listingType[@"categoriesSortBy"]);
    }
    return self;
}

@end
