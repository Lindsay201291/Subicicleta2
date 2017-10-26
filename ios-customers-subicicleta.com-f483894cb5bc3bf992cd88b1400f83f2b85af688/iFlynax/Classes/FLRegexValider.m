//
//  FLRegexValider.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/5/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLRegexValider.h"

@implementation FLRegexValider

+ (instancetype)validerWithRegex:(NSString *)regex andHint:(NSString *)hint {
    return [[self alloc] initWithRegex:regex andHint:hint];
}

- (instancetype)initWithRegex:(NSString *)regex andHint:(NSString *)hint {
    self.regex = regex;
    return [super initWithHint:hint];
}

- (instancetype)initWithHint:(NSString *)hint {
    return [self initWithRegex:nil andHint:hint];
}

- (BOOL)validate:(id)subject {
    if (!_regex) {
        return YES;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.regex];
    if ([subject isKindOfClass:UITextField.class]) {
        return [predicate evaluateWithObject:((UITextField *)subject).text];
    }
    
    return YES;
}

@end
