//
//  FLImageMGItemModel.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLImageMGItemModel.h"

@implementation FLImageMGItemModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[self alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [self init];
    if (self) {
        _imageId = [data[@"id"] integerValue];
        _thumbnailUrl = data[@"thumbnail"];
        _imageDescription = data[@"description"];
        _type = [self typeFromString:data[@"type"]];
    }
    return self;
}

- (BOOL)isNew {
    return !(BOOL)_imageId;
}

- (BOOL)isPrimary {
    return _type == FLImageMGItemTypeMain;
}

- (void)setPrimary:(BOOL)primary {
    _type = FLImageMGItemTypeMain;
}

- (NSString *)typeString {
    return [self typeString:_type];
}

- (FLImageMGItemType)typeFromString:(NSString *)typeString {
    return [typeString isEqualToString:@"main"] ? FLImageMGItemTypeMain : FLImageMGItemTypePhoto;
}

- (NSString *)typeString:(FLImageMGItemType)type {
    NSString *typeString;
    switch (type) {
        case FLImageMGItemTypeMain:
            typeString = @"main";
            break;
        case FLImageMGItemTypePhoto:
            typeString = @"photo";
            break;
    }
    return typeString;
}

@end
