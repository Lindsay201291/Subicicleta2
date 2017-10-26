//
//  FLMessageModel.m
//  iFlynax
//
//  Created by Alex on 6/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLMessageModel.h"

@implementation FLMessageModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[FLMessageModel alloc] initFromDictionary:data];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _mId = [[data objectForKey:@"id"] integerValue];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];

    [string appendFormat:@"id: %d\n", (int)self.mId];

    return string;
}

@end
