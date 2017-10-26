//
//  FLFieldPhoneCell.m
//  iFlynax
//
//  Created by Alex on 9/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldPhoneCell.h"
#import "FLTextField.h"

static NSInteger const kCodeLimit = 4;

@interface FLFieldPhoneCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet FLTextField *codeField;
@property (weak, nonatomic) IBOutlet FLTextField *areaField;
@property (weak, nonatomic) IBOutlet FLTextField *numberField;
@property (weak, nonatomic) IBOutlet UIView *codeFieldContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nsAreaNumberConstraint;
@end

@implementation FLFieldPhoneCell
@dynamic item;

- (void)cellDidLoad {
    [super cellDidLoad];

    _codeField.delegate   = self;
    _areaField.delegate   = self;
    _numberField.delegate = self;
}

- (void)cellWillAppear {
    self.fieldPlaceholder.text = self.item.placeholder;

    if (!self.item.codeField) {
        _nsAreaNumberConstraint.constant = 15;
        _codeFieldContent.hidden = YES;
    }
    else {
        _codeField.text               = self.item.valueCode ? F(@"%@", self.item.valueCode) : @"";
        _codeField.placeholder        = FLLocalizedString(@"placeholder_fieldPhone_code");
        _codeField.inputAccessoryView = self.actionBar;
    }

    _areaField.text                 = self.item.valueArea ? F(@"%@", self.item.valueArea) : @"";
    _areaField.placeholder          = FLLocalizedString(@"placeholder_fieldPhone_area");
    _areaField.inputAccessoryView   = self.actionBar;

    _numberField.text               = self.item.valueNumber ? F(@"%@", self.item.valueNumber) : @"";
    _numberField.placeholder        = FLLocalizedString(@"placeholder_fieldPhone_number");
    _numberField.inputAccessoryView = self.actionBar;

    // it's a for future purpose
    if (!self.item.extField) {
        //TODO: modify constraints
    }

    // errors trigger
    [self highlightAsFieldWithError:(self.item.errorMessage != nil)];
}

- (void)highlightAsFieldWithError:(BOOL)highlighted {
    if (self.item.codeField && [_areaField.text isEmpty]) {
        [self highlightInput:_codeField highlighted:highlighted];
    }

    if ([_areaField.text isEmpty]) {
        [self highlightInput:_areaField highlighted:highlighted];
    }

    if ([_numberField.text isEmpty]) {
        [self highlightInput:_numberField highlighted:highlighted];
    }

    if (self.item.extField) {
        //
    }

    if (!highlighted) {
        self.item.errorMessage = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(FLTextField *)textField {
    [self highlightInput:textField highlighted:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *_value = FLTrueString(textField.text);

    if (textField == _codeField) {
        self.item.valueCode = _value;
    }
    else if (textField == _areaField) {
        self.item.valueArea = _value;
    }
    else if (textField == _numberField) {
        self.item.valueNumber = _value;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length + string.length - range.length;

    if (textField == _codeField && newLength == kCodeLimit + 1) {
        return NO;
    }
    else if (textField == _areaField && newLength == self.item.areaLength + 1) {
        return NO;
    }
    else if (textField == _numberField && newLength == self.item.numberLength + 1) {
        return NO;
    }
    return YES;
}

#pragma mark - Handle events

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        [_codeField becomeFirstResponder];
    }
}

+ (BOOL)canFocusWithItem:(FLFieldPhone *)item {
    return YES;
}

- (UIResponder *)responder {
    return _codeField;
}

@end
