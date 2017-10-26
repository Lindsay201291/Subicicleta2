//
//  FLFieldTextCell.m
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldTextCell.h"
#import "FLListingFormModel.h"

//static CGFloat const kFlagPaddingRight = 8;

@interface FLFieldTextCell () <UITextFieldDelegate>
@end

@implementation FLFieldTextCell
@dynamic item;

- (void)cellDidLoad {
    [super cellDidLoad];

    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _textField.inputAccessoryView = self.actionBar;
    _textField.delegate           = self;
}

- (void)cellWillAppear {
    self.fieldPlaceholder.text = self.item.placeholder;

    _textField.keyboardType = self.item.keyboardType;
    _textField.placeholder  = self.item.placeholder;
    _textField.text         = self.item.value;

    // errors trigger
    [self highlightAsFieldWithError:(self.item.errorMessage != nil)];

    /* for future purpose
    if (self.item.model.multilingual && _textField.rightView == nil) {
        UIImage *langImage = [UIImage imageNamed:F(@"flag_%@", [FLListingFormModel sharedInstance].langCode)];
        CGRect flagRect = CGRectMake(0, 0, langImage.size.width + kFlagPaddingRight, langImage.size.height);
        UIImageView *langImageView = [[UIImageView alloc] initWithFrame:flagRect];
        langImageView.contentMode = UIViewContentModeLeft;
        langImageView.image = langImage;

        _textField.rightView = langImageView;
        _textField.rightViewMode = UITextFieldViewModeAlways;
    }
    */
}

- (void)highlightAsFieldWithError:(BOOL)highlighted {
    [self highlightInput:_textField highlighted:highlighted];

    if (!highlighted) {
        self.item.errorMessage = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField {
    self.item.value = textField.text;

    if (self.item.errorMessage) {
        [self highlightAsFieldWithError:NO];
    }

    if (self.item.textFieldDidChange) {
        self.item.textFieldDidChange(textField);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.item.value = textField.text;

    if (self.item.textFieldDidEndEditing) {
        self.item.textFieldDidEndEditing(textField);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length + string.length - range.length;
    NSInteger maxLength  = FLTrueInteger(self.item.model.values) ?: 50;
    return newLength < maxLength;
}

#pragma mark - Handle events

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [_textField becomeFirstResponder];
    }
}

+ (BOOL)canFocusWithItem:(FLFieldText *)item {
    return YES;
}

- (UIResponder *)responder {
    return _textField;
}

@end
