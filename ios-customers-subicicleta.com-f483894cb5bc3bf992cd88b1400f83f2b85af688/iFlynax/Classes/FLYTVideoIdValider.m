//
//  FLYTVideoIdValider.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYTVideoIdValider.h"

@implementation FLYTVideoIdValider

- (void)setRegex:(NSString *)regex {
    _regex = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
}

- (BOOL)validate:(id)subject {
    if ([subject isKindOfClass:UITextField.class]) {
        _extractedVideoId = ((UITextField *)subject).text;
        
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_regex
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        NSArray *matches = [regex matchesInString:_extractedVideoId
                                          options:0
                                            range:NSMakeRange(0, _extractedVideoId.length)];
        if (matches.count > 0) {
            _extractedVideoId = [_extractedVideoId substringWithRange:[matches.firstObject range]];
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9_-]{11,}+$"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
        
        NSTextCheckingResult *match = [regex firstMatchInString:_extractedVideoId
                                                        options:0
                                                          range:NSMakeRange(0, _extractedVideoId.length)];
        if (!match) {
            return NO;
        }
        
    }
    return YES;
}

@end
