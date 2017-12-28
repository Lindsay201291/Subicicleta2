//
//  FLValiderPasswordPolicy.m
//  iFlynax
//
//  Created by Alex on 10/5/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValiderPasswordPolicy.h"

static CGFloat const kMinLength = 5;
static CGFloat const kMaxLength = 20;

@implementation FLValiderPasswordPolicy

- (BOOL)validate:(id)subject {
    if ([subject isKindOfClass:UITextField.class]) {
        /*NSString *password = [(UITextField *)subject text];

        NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSRange digitsRange = [password rangeOfCharacterFromSet:digits];
        NSInteger length = password.length;

        return (length >= kMinLength && length <= kMaxLength && digitsRange.location != NSNotFound);*/
        
        NSString *password = [(UITextField *)subject text];
        NSInteger length = password.length;
        BOOL character = 0, digit = 0;
        
        for (int i = 0; i < length; i++) {
            unichar c = [password characterAtIndex:i];
            if(!character)
                character = [[NSCharacterSet letterCharacterSet] characterIsMember:c];
            if(!digit)
                digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
        }

        return (length >= kMinLength && length <= kMaxLength && digit && character);
    }
    return NO;
}

@end
