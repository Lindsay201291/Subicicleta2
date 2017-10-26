//
//  FLValiderEqualInput.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/6/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValiderEqualInput.h"

@interface FLValiderEqualInput ()

@property (strong, nonatomic) id toInputControl;

@end

@implementation FLValiderEqualInput

+ (instancetype)validerWithControl:(id)control withHint:(NSString *)hint {
    return [[self alloc] initWithControl:control withHint:hint];
}

- (instancetype)initWithControl:(id)control withHint:(NSString *)hint {
    _toInputControl = control;
    return [self initWithHint:hint];
}

- (BOOL)validate:(id)subject {
    
    if ([subject isKindOfClass:UITextField.class] && [_toInputControl isKindOfClass:UITextField.class]) {
        return [((UITextField *)subject).text isEqualToString:((UITextField *)_toInputControl).text];
    }
    
    return NO;
}

@end
