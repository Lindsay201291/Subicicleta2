//
//  FLRegexValider.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/5/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValider.h"

@interface FLRegexValider : FLValider {
@protected
    NSString *_regex;
}

@property (copy, nonatomic) NSString *regex;

+ (instancetype)validerWithRegex:(NSString *)regex andHint:(NSString *)hint;

@end
