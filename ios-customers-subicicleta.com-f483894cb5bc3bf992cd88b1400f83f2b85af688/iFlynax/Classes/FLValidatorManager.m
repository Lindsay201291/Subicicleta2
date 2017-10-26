//
//  FLValidatorManager.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValidatorManager.h"

@interface FLValidatorManager ()

@property (nonatomic, copy) NSMutableArray *validators;

@end

@implementation FLValidatorManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _validators = [NSMutableArray new];
    }
    return self;
}

- (void)addValidator:(FLInputControlValidator *)validator {
    [_validators addObject:validator];
}

- (BOOL)validate {
    for (FLInputControlValidator *validator in _validators) {
        [validator validate];
        [validator manageTooltipMessage];
        if (!validator.isValid) {
            [validator.inputControl becomeFirstResponder];
            return NO;
        }
    }
    return YES; 
}

@end
