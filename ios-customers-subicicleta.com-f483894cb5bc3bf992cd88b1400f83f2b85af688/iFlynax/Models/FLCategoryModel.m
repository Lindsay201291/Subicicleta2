//
//  FLCategoryModel.m
//  iFlynax
//
//  Created by Alex on 2/25/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLCategoryModel.h"

@implementation FLCategoryModel

+ (instancetype)fromDictionary:(NSDictionary *)category {
    return [[FLCategoryModel alloc] initFromDictionary:category];
}

- (instancetype)initFromDictionary:(NSDictionary *)category {
    self = [super init];
    if (self) {
        _cId       = [[category objectForKey:@"id"] integerValue];
        _level     = [[category objectForKey:@"level"] integerValue];
        _adsCount  = [[category objectForKey:@"count"] integerValue];
        _name      = FLCleanString([category objectForKey:@"name"]);
        _key       = FLCleanString([category objectForKey:@"key"]);
        _path      = FLCleanString([category objectForKey:@"path"]);
        _locked    = [[category objectForKey:@"lock"] boolValue];
        _children  = [[category objectForKey:@"childrens"] boolValue];

        if (_children) {
            _subCategories = @[];

            if (category[@"subCategories"] != nil) {
                _subCategories = [category objectForKey:@"subCategories"];
            }
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];
    
    [string appendFormat:@"cId: %d\n", (int)self.cId];
    [string appendFormat:@"level: %d\n", (int)self.level];
    [string appendFormat:@"adsCount: %d\n", (int)self.adsCount];
    [string appendFormat:@"name: %@\n", self.name];
    [string appendFormat:@"key: %@\n", self.key];
    [string appendFormat:@"path: %@\n", self.path];
    [string appendFormat:@"locked: %@\n", self.locked ? @"YES" : @"NO"];
    [string appendFormat:@"children: %@\n", self.children ? @"YES" : @"NO"];

    if (self.children) {
        [string appendFormat:@"subCategories: %@\n", self.subCategories];
    }

    return string;
}

@end
