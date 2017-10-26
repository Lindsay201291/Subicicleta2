//
//  FLFieldDateCell.m
//  iFlynax
//
//  Created by Alex on 10/13/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLFieldDateCell.h"
#import "FLTextField.h"

@interface FLFieldDateCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet FLTextField *fieldFrom;
@property (weak, nonatomic) IBOutlet FLTextField *fieldTo;

@property (assign, nonatomic) FLTextField     *currentResponder;
@property (strong, nonatomic) UIDatePicker    *datePicker;
@property (strong, nonatomic) NSDateFormatter *formatter;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *betweenSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *singleFieldTrailingConstraint;

@property (nonatomic, getter=isBothFields) BOOL bothFields;

@end

@implementation FLFieldDateCell
@dynamic item;

- (void)cellDidLoad {
    [super cellDidLoad];

    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = FLConfigWithKey(@"forms_date_format");

    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker addTarget:self action:@selector(datePickerdDidChange:)
          forControlEvents:UIControlEventValueChanged];

    _fieldFrom.inputAccessoryView = self.actionBar;
    _fieldFrom.inputView          = _datePicker;
    _fieldFrom.delegate           = self;
}

- (void)cellWillAppear {
    self.fieldPlaceholder.text = self.item.placeholder;

    _bothFields = (self.item.type == FLFieldDateTypePeriod);
    _fieldTo.hidden = !_bothFields;

    _fieldFrom.text = self.item.valueFrom;
    _fieldFrom.placeholder = (self.item.type == FLFieldDateTypePeriod
                              ? self.item.placeholderFrom
                              : self.item.placeholder);

    if (self.item.type == FLFieldDateTypePeriod) {
        if (_fieldTo.delegate == nil) {
            _fieldTo.inputAccessoryView = self.actionBar;
            _fieldTo.inputView          = _datePicker;
            _fieldTo.delegate           = self;
        }

        _fieldTo.text        = self.item.valueTo;
        _fieldTo.placeholder = self.item.placeholderTo;
    }

    // errors trigger
    [self highlightAsFieldWithError:(self.item.errorMessage != nil)];
}

- (void)highlightAsFieldWithError:(BOOL)highlighted {
    [self highlightInput:_fieldFrom highlighted:highlighted];

    if (self.item.type == FLFieldDateTypePeriod) {
        [self highlightInput:_fieldTo highlighted:highlighted];
    }

    if (!highlighted) {
        self.item.errorMessage = nil;
    }
}

#pragma mark - Accessors

- (void)updateConstraints {
    [super updateConstraints];
    _widthConstraint.active = _bothFields;
    _betweenSpacingConstraint.active = _bothFields;
    _singleFieldTrailingConstraint.active = !_bothFields;
}

#pragma mark -

+ (BOOL)canFocusWithItem:(FLFieldDate *)item {
    return YES;
}

- (FLTextField *)currentResponder {
    return [_fieldFrom isFirstResponder] ? _fieldFrom : _fieldTo;
}

- (UIResponder *)responder {
    return _fieldFrom;
}

#pragma mark - UIDatePickerDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSDate *date = [NSDate date];

    if (textField.text.length) {
        date = [_formatter dateFromString:textField.text];
    }

    [_datePicker setDate:date];
}

#pragma mark - UIDatePickerDelegate

- (void)datePickerdDidChange:(UIDatePicker *)datePicker {
    NSString *dateString = [_formatter stringFromDate:datePicker.date];
    self.currentResponder.text = dateString;

    if ([_fieldFrom isFirstResponder]) {
        self.item.valueFrom = dateString;
    }
    else {
        self.item.valueTo = dateString;
    }

    [self highlightAsFieldWithError:NO];
}

@end
