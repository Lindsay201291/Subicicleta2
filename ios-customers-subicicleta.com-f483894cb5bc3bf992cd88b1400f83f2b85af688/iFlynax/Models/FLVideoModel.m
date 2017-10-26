//
//  FLVideoModel.m
//  iFlynax
//
//  Created by Alex on 7/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLVideoModel.h"

@implementation FLVideoModel

+ (instancetype)fromDictionary:(NSDictionary *)video {
    return [[FLVideoModel alloc] initFromDictionary:video];
}

- (instancetype)initFromDictionary:(NSDictionary *)video {
    self = [super init];
    if (self) {
        _vId       = [[video objectForKey:@"ID"] integerValue];
        _type      = [self videoTypeFromString:[video objectForKey:@"type"]];

        _preview   = FLCleanString([video objectForKey:@"preview"]);
        _urlString = FLCleanString([video objectForKey:@"video"]);
    }
    return self;
}

- (FLVideoType)videoTypeFromString:(NSString *)typeString {
    if ([typeString isEqualToString:@"youtube"]) {
        return FLVideoTypeYouTube;
    }
    return FLVideoTypeLocal;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"\n"];

    [string appendFormat:@"id: %d\n", (int)self.vId];
    [string appendFormat:@"type: %@\n", self.type == FLVideoTypeLocal ? @"local" : @"youtube"];
    [string appendFormat:@"urlString: %@\n", self.urlString];
    [string appendFormat:@"preview: %@\n", self.preview];

    return string;
}

@end
