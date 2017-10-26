//
//  FLValider.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValider.h"

@implementation FLValider

+ (instancetype)validerWithHint:(NSString *)hint {
    return [[self alloc] initWithHint:hint];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hint = @"";
        _autoValidated = YES;
        _autoHinted = YES;
    }
    return self;
}

- (instancetype)initWithHint:(NSString *)hint {
    self = [self init];
    _hint = hint;
    return self;
}

- (BOOL)validate:(id)subject {
    return YES;
}

@end