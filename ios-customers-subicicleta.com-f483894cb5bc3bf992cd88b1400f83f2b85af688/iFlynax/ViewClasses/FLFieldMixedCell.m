//
//  FLFieldMixedCell.m
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldMixedCell.h"
#import "FLTextField.h"
#import "FLDropDown.h"

@interface FLFieldMixedCell ()
@property (weak, nonatomic) IBOutlet FLTextField *textFieldFrom;
@property (weak, nonatomic) IBOutlet FLTextField *textFieldTo;
@property (weak, nonatomic) IBOutlet FLDropDown *dropDown;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *equaWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horConstraint;
@end

@implementation FLFieldMixedCell
@dynamic item;

- (void)setupNumberField:(FLTextField *)field {
    field.keyboardType = UIKeyboardTypeNumberPad;
    field.inputAccessoryView = self.actionBar;

    [field addTarget:self action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
}

- (void)setTwoFields:(BOOL)twoFields {
    _equaWidthConstraint.active = twoFields;
    _widthConstraint.active = !twoFields;
    _textFieldTo.hidden = !twoFields;
    _horConstraint.constant = twoFields ? 8 : 0;
    _twoFields = twoFields;
}

#pragma mark -

- (void)cellDidLoad {
    [super cellDidLoad];

    [self setupNumberField:_textFieldFrom];
    [self setupNumberField:_textFieldTo];

    _widthConstraint.constant = 0;
}

- (void)cellWillAppear {
    self.fieldPlaceholder.text = self.item.placeholder;
    self.twoFields = self.item.model.searchMode;

    [_dropDown clearDataSource];

    if ([self.item.options isKindOfClass:NSArray.class]
        && [self.item.options count])
    {
        for (id option in self.item.options) {
            [_dropDown addOption:option];
        }
        [_dropDown reloadAllComponents];

        _dropDown.didChangeBlock = ^(id option, NSString *key) {
            self.item.selectValue = option;
        };
        
        if (!self.item.selectValue) {
            self.item.selectValue = self.item.options[0];
        }

        [_dropDown selectOption:self.item.selectValue];
    }
    _dropDown.inputAccessoryView = self.actionBar;

    if (self.item.model.searchMode) {
        _textFieldFrom.text = self.item.valueFrom;
        _textFieldFrom.placeholder = self.item.placeholderFrom;

        _textFieldTo.text = self.item.valueTo;
        _textFieldTo.placeholder = self.item.placeholderTo;
    } else {
        _textFieldFrom.text = FLCleanString(self.item.valueFrom);
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

#pragma mark - Handle events

+ (BOOL)canFocusWithItem:(RETableViewItem *)item {
    return YES;
}

- (UIResponder *)responder {
    return _textFieldFrom;
}

@end
