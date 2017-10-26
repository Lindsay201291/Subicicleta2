//
//  FLValiderEmail.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/5/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValiderEmail.h"

@implementation FLValiderEmail

- (void)setRegex:(NSString *)regex {
    _regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
}

@end
