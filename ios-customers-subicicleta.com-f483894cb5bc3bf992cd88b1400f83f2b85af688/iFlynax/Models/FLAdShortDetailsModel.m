//
//  FLAdShortDetailsModel.m
//  iFlynax
//
//  Created by Alex on 6/5/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAdShortDetailsModel.h"

@implementation FLAdShortDetailsModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[FLAdShortDetailsModel alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _lId         = [[data objectForKey:@"id"] integerValue];
        _sellerId    = [[data objectForKey:@"sellerId"] integerValue];
        _photosCount = [[data objectForKey:@"photos_count"] integerValue];

        _title       = FLCleanString([data objectForKey:@"title"]);
        _subTitle    = FLCleanString([data objectForKey:@"middle_field"]);
        _price       = FLCleanString([data objectForKey:@"price"]);

        NSString *_thumbnailStringUrl = (data[@"thumbnail"] != nil
                                         ? [data objectForKey:@"thumbnail"]
                                         : [data objectForKey:@"photo"]);

        _thumbnail   = [NSURL URLWithString:_thumbnailStringUrl];
        _featured    = FLTrueBool(data[@"featured"]);

        //TODO: replace the dict to model
        if (data[@"map"] != nil) {
            _location = @{@"lat"  : [NSNumber numberWithDouble:[data[@"map"][@"lat"] doubleValue]],
                          @"lng"  : [NSNumber numberWithDouble:[data[@"map"][@"lng"] doubleValue]],
                          @"title": FLCleanString(data[@"map"][@"title"])};
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];

    [string appendFormat:@"lId: %d\n", (int)self.lId];
    [string appendFormat:@"sellerId: %d\n", (int)self.sellerId];
    [string appendFormat:@"photosCount: %d\n", (int)self.photosCount];
    [string appendFormat:@"title: %@\n", self.title];
    [string appendFormat:@"subTitle: %@\n", self.subTitle];
    [string appendFormat:@"price: %@\n", self.price];
    [string appendFormat:@"thumbnail: %@\n", self.thumbnail];
    [string appendFormat:@"featured: %@\n", self.featured ? @"YES" : @"NO"];
    [string appendFormat:@"location: %@\n", self.location];

    return string;
}

@end
