//
//  FLValiderRequired.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 9/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLValiderRequired.h"
#import "FLDropDown.h"

@implementation FLValiderRequired

- (BOOL)validate:(id)subject {
    if ([subject isKindOfClass:UITextField.class]) {
        return ((UITextField *)subject).text.length > 0;
    }
    else if ([subject isKindOfClass:UITextView.class]) {
        return ((UITextView *)subject).text.length > 0;
    }
    else if ([subject isKindOfClass:FLDropDown.class]) {
        return ((FLDropDown *)subject).isSelected;
    }
    return YES;
}

@end