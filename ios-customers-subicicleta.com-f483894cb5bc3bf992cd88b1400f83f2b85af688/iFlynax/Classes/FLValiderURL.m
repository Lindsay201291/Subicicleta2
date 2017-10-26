//
//  FLValiderURL.m
//  iFlynax
//
//  Created by Alex on 11/16/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValiderURL.h"

@implementation FLValiderURL

- (void)setRegex:(NSString *)regex {
    _regex = @"((?:http|https)://)?([\\w\\d\\-_]+\\.)?[\\w\\d\\-_]+\\.\\w{2,5}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?";
}

@end
