//
//  FLValid.m
//  iFlynax
//
//  Created by Alex on 9/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLValid.h"

@implementation FLValid

+ (instancetype)sharedInstance {
	static FLValid *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	return _sharedInstance;
}

+ (NSString *)cleanString:(id)input {
    if (input != nil && input != [NSNull null]) {
        if ([input isKindOfClass:NSString.class]) {
            input = [input stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            input = [input stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"'"];
            input = [input stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            input = [input stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
            input = [input stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            input = [input stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];

            // return clean string
            return input;
        }
    }
    return @"";
}

@end
