//
//  FLFieldNumberCell.m
//  iFlynax
//
//  Created by Alex on 8/31/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldNumberCell.h"

@interface FLFieldNumberCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet FLTextField *textFieldFrom;
@property (weak, nonatomic) IBOutlet FLTextField *textFieldTo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *equaWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horConstraint;
@end

@implementation FLFieldNumberCell
@dynamic item;

- (void)setupNumberField:(FLTextField *)field {
    [field addTarget:self action:@selector(textFieldDidChange:)
    forControlEvents:UIControlEventEditingChanged];

    field.keyboardType       = UIKeyboardTypeDecimalPad;
    field.inputAccessoryView = self.actionBar;
    field.delegate           = self;
}

- (void)cellDidLoad {
    [super cellDidLoad];

    [self setupNumberField:_textFieldFrom];
    [self setupNumberField:_textFieldTo];

    _widthConstraint.constant = 0;
}

- (void)setTwoFields:(BOOL)twoFields {
    _equaWidthConstraint.active = twoFields;
    _widthConstraint.active = !twoFields;
    _textFieldTo.hidden = !twoFields;
    _horConstraint.constant = twoFields ? 8 : 0;
    _twoFields = twoFields;
}

- (void)cellWillAppear {
    self.fieldPlaceholder.text = self.item.placeholder;
    self.twoFields = self.item.model.searchMode;

    if (self.item.model.searchMode) {
        _textFieldFrom.text        = self.item.valueFrom;
        _textFieldFrom.placeholder = self.item.placeholderFrom;

        _textFieldTo.text        = self.item.valueTo;
        _textFieldTo.placeholder = self.item.placeholderTo;
    }
    else {
        _textFieldFrom.text        = self.item.valueFrom;
        _textFieldFrom.placeholder = self.item.placeholder;
    }

    // errors trigger
    [self highlightAsFieldWithError:(self.item.errorMessage != nil)];
}

- (void)highlightAsFieldWithError:(BOOL)highlighted {
    [self highlightInput:_textFieldFrom highlighted:highlighted];

    if (!highlighted) {
        self.item.errorMessage = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(FLTextField *)textField {
    if (textField == _textFieldFrom) {
        self.item.valueFrom = textField.text;
    } else {
        self.item.valueTo = textField.text;
    }

    if (self.item.errorMessage) {
        [self highlightAsFieldWithError:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Handle events

+ (BOOL)canFocusWithItem:(RETableViewItem *)item {
    return YES;
}

- (UIResponder *)responder {
    return _textFieldFrom;
}

@end
