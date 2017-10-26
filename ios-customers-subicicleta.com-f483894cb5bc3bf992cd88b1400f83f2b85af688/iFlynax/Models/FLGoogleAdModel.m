//
//  FLGoogleAdModel.m
//  iFlynax
//
//  Created by Alex on 5/2/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLGoogleAdModel.h"

static NSString * const kResponseKeyPosition = @"side";
static NSString * const kResponseKeyCode     = @"code";

static FLBannerPosition _stringPositionToInteger(NSString *position) {
    if ([position isEqualToString:@"top"]) {
        return FLBannerPositionTop;
    }
    return FLBannerPositionBottom;
}

@implementation FLGoogleAdModel {
    NSString *_positionString;
}

+ (instancetype)fromDictionary:(NSDictionary *)dict {
    return [[FLGoogleAdModel alloc] initFromDictionary:dict];
}

- (instancetype)initFromDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _positionString = FLTrueString(dict[kResponseKeyPosition]);

        _position = _stringPositionToInteger(_positionString);
        _unitID   = FLTrueString(dict[kResponseKeyCode]);
        _height   = kGoogleAdHeight;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:[super description]];
    [string appendFormat:@"\nPosition: %@", _positionString];
    [string appendFormat:@"\nUnit ID: %@", _unitID];
    [string appendFormat:@"\nHeight: %.1f", _height];

    return string;
}

@end
